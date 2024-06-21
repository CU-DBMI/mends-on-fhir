# A short list of steps so far:

- Unpacked a distribution (built with March 14th upstream source code) into `Whistle2/distribution`
- Created a simple script `Whistle2/bin/run-demo-1.sh` to transform the `input-examples/omop-fhir-data/synthea-cohort-010` files
  - It breaks after the first file to speed up debugging
  - Output goes to `Whistle2/output`
- Copied `whistle-mappings/synthea` to  `whistle-mappings/synthea-w2` to edit for Whistle 2.
  - A commit was made before making any changes.
- Made the following changes so far:
  - All `.wstl` files declare package `main` so all function calls are to the same package (since they are not package-qualified)
  - Updated the `if` conditionals to use `then` before the opening braces. This is W2 syntax.
  - Quality is now `==` instead of `=` and inequality is `!=` instead of `~=`
  - There might be an issue with end of line comments not working. See around line 88 in Code_Map.wstl.
  - Started to change some of the builtin functions to the new names. For example, `$ToUpper` is now `toUpper`
    - See: https://github.com/GoogleCloudPlatform/healthcare-data-harmonization/blob/master/doc/builtins.md
  - Variable declarations are now scoped. We need to declare the variable at the highest scope we need it in.
    - See: https://github.com/GoogleCloudPlatform/healthcare-data-harmonization/blob/master/doc/spec.md#user-content-scope-scope
    - This required the addition of a few declarations.
  - Added the `var` keyword to a few lines where the intention was to be a var but it worked before without the keyword.
  - The `rounting` we did in `zzOmop531Impl.wstl` needed to be updated to use a different syntax.
    - As far as I can tell, the previous conditional mapping syntax is no longer part of Whistle 2
    - Conditional mapping in Whistle 1: https://github.com/GoogleCloudPlatform/healthcare-data-harmonization/blob/master/wstl1/mapping_language/doc/reference.md#user-content-conditional-mapping
    - Conditional syntax in Whistle 2: https://github.com/GoogleCloudPlatform/healthcare-data-harmonization/blob/master/doc/spec.md#user-content-conditionalternary-expressions-conditional-ternary-expressions
- Created a new main entry file to do the importing and the first call
  - See `whistle-mappings/synthea-w2/w2-main.wstl`
  - It needs to be placed in the directory that forms the root of the import paths since imports are relative to the directory of the main file used in the cli call.
- For harmonization
  - Built and included the harmonization plugin
  - Renamed the mapping files to the new naming convention.
  - Fixed the `Each element of ConceptMap mush have at least one target` error for the ConceptMap files by deleting the entries that do not have a target.
  - Each map file must have a version declared.
- Fixed a few more built-ins.
- 

I think the above list covers all the changes in the first commit of mapping changes.

# TODO

- Update all the builtin calls as needed.
- Iterate with running the `bin/run-synthea-w2-cohort-1001.sh` until there are no errors.
  - Then remove the break like to run all 10 files
- Try a larger cohort when things look good.
- The string splitting built-in might behave a little different from W1 in terms of trimming extra spaces, ignoring empty splits, etc. I left a TODO: note at each site to make sure we get back to this to make sure the intended splitting is still working. 