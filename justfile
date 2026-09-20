set shell := ["bash", "-c"]

PACKAGER_URL := "https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh"
SCHEMA_URL := "https://raw.githubusercontent.com/Meorawr/wow-ui-schema/main/UI.xsd"

default: all

all: wow wow_anniversary wow_classic wow_classic_era wow_classic_titan

check:
    @luacheck -q $(git ls-files '*.lua')
    @xmllint --schema <(curl -s {{SCHEMA_URL}}) --noout $(git ls-files '*.xml')

dist:
    @curl -s {{PACKAGER_URL}} | bash -s -- -dl

libs:
    @curl -s {{PACKAGER_URL}} | bash -s -- -cdz
    @mkdir -p Libs/
    @cp -a .release/TextureAtlasViewer/Libs/* Libs/

wow_classic:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic >Data_Mists.lua

wow_classic_beta:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_beta >Data_Forever.lua

wow_classic_ptr:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_ptr >Data_Mists.lua

wow_classic_era:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_era >Data_Vanilla.lua

wow_classic_era_ptr:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_era_ptr >Data_Vanilla.lua

wow_anniversary:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_anniversary >Data_TBC.lua

wow_anniversary_ptr:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_anniversary_ptr >Data_TBC.lua

wow_classic_titan:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_titan >Data_Wrath.lua

wow_classic_titan_ptr:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_titan_ptr >Data_Wrath.lua

wow:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow >Data_Standard.lua
wow_beta:
    pwsh Scripts/Generate-Atlases.ps1 -Product wow_beta >Data_Standard.lua

wowt:
    pwsh Scripts/Generate-Atlases.ps1 -Product wowt >Data_Standard.lua

wowxptr:
    pwsh Scripts/Generate-Atlases.ps1 -Product wowxptr >Data_Standard.lua
