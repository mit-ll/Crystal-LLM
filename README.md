**Crystal Large Language Models (LLM) user interface**

**Author:** Darrell O. Ricke, Ph.D.  (Darrell.Ricke@ll.mit.edu )

**RAMS request ID 1026697**

**Overview:**
Large Language Models (LLM) user interface

**Citation:** None

**Disclaimer:**
DISTRIBUTION STATEMENT A. Approved for public release. Distribution is unlimited.

This material is based upon work supported by the Department of the Air Force
under Air Force Contract No. FA8702-15-D-0001. Any opinions, findings,
conclusions or recommendations expressed in this material are those of the
author(s) and do not necessarily reflect the views of the Department of the Air Force.

© 2024 Massachusetts Institute of Technology.

The software/firmware is provided to you on an As-Is basis

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
U.S. Government rights in this work are defined by DFARS 252.227-7013 or
DFARS 252.227-7014 as detailed above. Use of this work other than as specifically
authorized by the U.S. Government may violate any copyrights that exist in this work.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

## Overview
```
Ruby on Rails user interface for Large Language Models (LLM)
```
**To build Docker image:**

  docker build . -t crystal_llm:latest

**To run with Docker compose:**

  docker-compose up

  Open web browser to port 3000

**To compile Singularity sandbox:**

  singularity build --sandbox crystal_llm_box crystal_llm.def

**To run Singularity sandbox:**

  singularity run -w crystal_llm_box
