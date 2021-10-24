const CMDSTAN_HOME_VAR = "JULIA_CMDSTAN_HOME"

"""

Get the path to the `CMDSTAN_HOME` environment variable.

$(SIGNATURES)

# Extended help

Example: `get_cmdstan_home()`
"""
function get_cmdstan_home()
    get(ENV, CMDSTAN_HOME_VAR) do
        throw(ErrorException("The environment variable $CMDSTAN_HOME_VAR needs to be set."))
    end
end

"""

Set the path for `CMDSTAN_HOME`.

$(SIGNATURES)

# Extended help

Example: `set_cmdstan_home!(homedir() * "/Projects/Stan/cmdstan/")`
"""
