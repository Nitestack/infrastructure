local keymaps = require("core.mappings")

require("utils.mappings").map(keymaps.mappings, keymaps.mapping_opts)
require("utils.mappings").disable_mapping(keymaps.unmappings)
