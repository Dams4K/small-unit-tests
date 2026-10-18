# Small Unit Tests
I find other addons, like [GUT](https://github.com/bitwes/Gut) or [GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4), too intrusive in the editor. They look ugly and seem out of place. I just want a simple button to run all my tests and that's all. Everything can be done in the output imo.

## Installation
In your project root:
```bash
git submodule add https://github.com/Dams4K/small-unit-tests.git addons/sut
```

## Usage
Every test files must be under the `res://tests` folder, starting with the prefix `test_` and must extends the class `TestCase`. Each methods should also starts with the prefix `test_`.

To run all the tests click on the button next to the movie maker mode, or call the `res://addons/sut/run.gd` in cli: `./godot --headless --path . -s res://addons/sut/run.gd`.
