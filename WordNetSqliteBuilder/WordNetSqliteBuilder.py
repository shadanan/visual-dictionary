#!/usr/bin/env python2.7
import os, sqlite3

class WordNetSqliteBuilder(object):
    def __init__(self):
        wordnet_file = '../GraphVisualizer/wordnet.sqlite'

        try:
            os.remove(wordnet_file)
        except:
            pass

        self.conn = sqlite3.connect(wordnet_file)

    def create_tables(self):
        cur = self.conn.cursor()

        # Create tables and indices
        cur.execute("CREATE TABLE words_meanings (word TEXT, meaning TEXT, UNIQUE(word, meaning))")
        cur.execute("CREATE INDEX word_index ON words_meanings (word, meaning)")
        cur.execute("CREATE INDEX meaning_index ON words_meanings (meaning)")

        cur.execute("CREATE TABLE definitions (meaning TEXT PRIMARY KEY, definition TEXT)")
        cur.execute("CREATE INDEX definition_index ON definitions (meaning)")

    # Load functions
    def load_index(self, index_file):
        cur = self.conn.cursor()

        with open(index_file, 'r') as fp:
            lines = fp.readlines()

        for line in lines:
            if line.startswith('  '):
                continue

            line = line.strip()
            tokens = line.split()
            word = tokens[0].replace('_', ' ')

            for meaning_index in tokens[-int(tokens[2]):]:
                meaning = tokens[1] + meaning_index
                cur.execute("INSERT INTO words_meanings (word, meaning) VALUES (?, ?)", (word, meaning))

    def load_data(self, data_file):
        cur = self.conn.cursor()

        with open(data_file, 'r') as fp:
            lines = fp.readlines()

        for line in lines:
            if line.startswith('  '):
                continue

            line = line.strip()
            tokens, definition = line.split(' | ')
            tokens = tokens.split()

            if tokens[2] == 's':
                meaning = 'a' + tokens[0]
            else:
                meaning = tokens[2] + tokens[0]

            cur.execute("INSERT INTO definitions (meaning, definition) VALUES (?, ?)", (meaning, definition))

    def commit(self):
        self.conn.commit()

def main():
    os.chdir(os.path.dirname(os.path.realpath(__file__)))

    wordnet = WordNetSqliteBuilder()

    wordnet.create_tables()

    wordnet.load_index("index.adv")
    wordnet.load_data("data.adv")

    wordnet.load_index("index.adj")
    wordnet.load_data("data.adj")

    wordnet.load_index("index.noun")
    wordnet.load_data("data.noun")

    wordnet.load_index("index.verb")
    wordnet.load_data("data.verb")

    wordnet.commit()

if __name__ == '__main__':
    main()
