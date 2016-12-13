#!/bin/bash

type="docx"

cd ../labs/

pandoc -S \
-o ../pandoc/test.$type \
--standalone \
--smart \
--self-contained \
--variable urlcolor=cyan \
../pandoc/title.yaml \
../pandoc/pandoc-Azure\ Marketplace.md \
Lab\ 0\ -\ Provisioning.md \
Lab\ 1\ -\ Accessing\ the\ Cluster.md \
Lab\ 2\ -\ CQL.md \
Lab\ 3\ -\ Primary\ Keys.md \
Lab\ 4\ -\ Consistency.md \
Lab\ 5\ -\ Search.md \
Lab\ 6\ -\ Analytics.md \
Lab\ 7\ -\ Graph.md \
Lab\ 8\ -\ Operations.md

