#!/bin/bash
grep -rl TODO . | xargs sed -i 's/TODO/notaTODO/g'
grep -rl FIXME . | xargs sed -i 's/FIXME/notaFIXME/g'
