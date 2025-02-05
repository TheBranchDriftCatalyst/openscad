#

A modern monorepo structure for open scad paramatric design.

## Project TODO

- lots of stuff to do but, basic command is now working
  - `poetry run python -m openscad --verbose`
  - run from inside the project directory to build
    - [ ] add --rebuild flag and 
      - [ ] make default not to rebuild if file exists
    - [x] fix tqdm, get rid of it and use rich instead
    - NOTE: openscad command output is pretty non exisitant... its either done or not lulz
      - fix log output and routing for parralel tasks
      - [x] things are not running in parallel either
    - [ ] write script to fix fontconfig issue (taskfile)
  - [ ] fix issue with jinja filters not avaliable, pita
  - [ ] need to still add the ability to run from outside the project directory
  - [ ] add pydantic --> scad transformation schema layer
    - this will allow aliasing of scad parameters (Line_2_Width can be alised to brand, etc).  See filament swatches for example use case
- [ ] extract into git submodule, self repo