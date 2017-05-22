### Jenkins

This folder describes the config and scripts files used for Jenkins execution.

### Structure 

We made a individual folder set for each operational system described above.

- **all** - Defines a common files used among operational systems. (`config.lua` and `test.lua`);
- **linux** - Defines scripts files for Linux environment. (`ubuntu-14.04`);
- **win** - Defines scripts files for Windows environment;
- **mac** - Defines scripts files for Mac OSX environment. (`mac-el-capitan`);

Feel free to edit them and Jenkins will execute when a GitHub Pull Request triggered or even daily builds.

### Tips

If you would like to change TerraLib branch, look for `_TERRALIB_BRANCH` in `terrame-terralib*.sh|bat`.
