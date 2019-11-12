You can safely ignore everything in this directory.

There are two scripts in this directory.

-   `dependencies-update`
-   `docs-generate`

They are designed to be called with no arguments, and can be called from any working directory, though they both modify the source code in place.

`dependencies-update` updates the dependencies in <../nix/sources.json> with a tool called [Niv](https://github.com/nmattia/niv).

`docs-generate` will execute any `SRC` blocks in Org mode files, modifying them in place. And then it generate GitHub Flavored Markdown files from them.

There's also a `setup.org` file with common setup for all the Org mode files in this project.
