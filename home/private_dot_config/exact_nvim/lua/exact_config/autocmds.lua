local commands = require("core.commands")

require("utils.cmds").auto_cmds(commands.auto_cmds, commands.auto_cmd_opts, commands.au_group_opts)
require("utils.cmds").user_cmds(commands.user_cmds, commands.user_cmd_opts)
