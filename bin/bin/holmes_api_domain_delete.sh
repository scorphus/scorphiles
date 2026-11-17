#!/bin/bash

mysql -u root holmes -e "DELETE FROM facts WHERE review_id IN (
    SELECT DISTINCT id FROM reviews WHERE page_id in (
        SELECT DISTINCT id FROM pages WHERE domain_id = $1
    )
);

DELETE FROM violations WHERE review_id IN (
    SELECT DISTINCT id FROM reviews WHERE page_id in (
        SELECT DISTINCT id FROM pages WHERE domain_id = $1
    )
);

UPDATE pages SET last_review_id=null where domain_id = $1;

DELETE FROM reviews WHERE page_id in (
    SELECT DISTINCT id FROM pages WHERE domain_id = $1
);

DELETE FROM pages WHERE domain_id = $1;
DELETE FROM domains WHERE id = $1;
"
