How to add task template to Delphi repository.

1. Start Delphi with Administrator privileges
2. Open template unit - uTask_Tpl.pas
3. Select all and open popup menu -> select "Add to Repository"
4. Fill the form and save

It will result in new Item in %AppData%\Roaming\Embarcadero\BDS\19.0\Repository.xml file:

<Item IDString="uTask_Tpl.pas" CreatorIDString="SourceCreator">
  <Name Value="Task"/>
  <Icon Value="Advent-Of-Code\Template\AoC.ico"/>
  <Description Value="Advent of Code Task"/>
  <Author Value="Mike Stanin"/>
  <Personality Value=""/>
  <Platforms Value=""/>
  <Frameworks Value=""/>
  <Identities Value="RADSTUDIO"/>
  <Categories>
    <Category Value="InternalRepositoryCategory.Advent of Code" Parent="Borland.Delphi.New">Advent of Code</Category>
    <Category Value="Borland.Delphi.New" Parent="Borland.Root">Delphi Projects</Category>
  </Categories>
  <Buffer>uTask_Tpl.pas</Buffer>
</Item>
