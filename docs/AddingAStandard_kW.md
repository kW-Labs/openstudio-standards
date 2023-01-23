## 1. Edit Standards Workbooks
1. Download spreadsheets from google docs. Save a copy and edit to include standards information you want
2. Save spreadsheets in openstudio_standards/data/standards
3. Edit Rakefile to only include edited spreadsheet files as `spreadsheet_titles`
  - Actually just name the same as the existing OpenStudio_Standards-deer.xlsx and OpenStudio_Standards-deer(space_types).xlsx

4. Run `bundle exec rake data:update:manual` to write spreadsheet info to jsons
5. Create new class
6. add 'require' pointing to new class in /lib/openstudio-standards/standards/standards.rb
7. add too `templates` array in lib/openstudio-standards/prototypes/common/prototype_metaprogramming.rb
