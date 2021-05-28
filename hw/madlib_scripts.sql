DROP TABLE IF EXISTS documents;
CREATE TABLE documents(docid INT4, contents TEXT);
INSERT INTO documents VALUES
(0, 'I like to eat broccoli and bananas. I ate a banana and spinach smoothie for breakfast.'),
(1, 'Chinchillas and kittens are cute.'),
(2, 'My sister adopted two kittens yesterday.'),
(3, 'Look at this cute hamster munching on a piece of broccoli.'),
(0, 'I like to eat broccoli and bananas. I ate a banana and spinach smoothie for breakfast.');

ALTER TABLE documents ADD COLUMN words TEXT[];
UPDATE documents SET words = tsvector_to_array(to_tsvector('english',contents))

SELECT * FROM documents ORDER BY docid;

DROP TABLE IF EXISTS documents_tf, documents_tf_vocabulary;
SELECT madlib.term_frequency('public.documents',    -- input table
                             'docid',        -- document id column
                             'words',        -- vector of words in document
                             'public.documents_tf'  -- output table
                            );
							
							
SELECT * FROM documents_tf ORDER BY docid;