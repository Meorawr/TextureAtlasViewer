SHELL := /bin/bash
LIBDIR := Libs
PACKAGER_URL := https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh
SCHEMA_URL := https://raw.githubusercontent.com/Meorawr/wow-ui-schema/main/UI.xsd

.PHONY: check data dist libs
.FORCE:

all: wow wow_beta wow_classic_beta wow_classic_era

check:
	@luacheck -q $(shell git ls-files '*.lua')
	@xmllint --schema <(curl -s $(SCHEMA_URL)) --noout $(shell git ls-files '*.xml')

dist:
	@curl -s $(PACKAGER_URL) | bash -s -- -d -l

libs:
	@curl -s $(PACKAGER_URL) | bash -s -- -c -d -z
	@mkdir -p Libs/
	@cp -a .release/TextureAtlasViewer/Libs/* Libs/

wow_classic:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_CATACLYSM >Data_Cata.lua

wow_classic_beta:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_CATACLYSM >Data_Cata.lua

wow_classic_ptr:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_CATACLYSM >Data_Cata.lua

wow_classic_era:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_CLASSIC >Data_Vanilla.lua

wow_classic_era_ptr:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_CLASSIC >Data_Vanilla.lua

wow:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_DRAGONFLIGHT >Data_Mainline.lua

wow_beta:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel 10 >Data_TWW.lua

wowt:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_DRAGONFLIGHT >Data_Mainline.lua

wowxptr:
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ -ExpansionLevel LE_EXPANSION_DRAGONFLIGHT >Data_Mainline.lua
