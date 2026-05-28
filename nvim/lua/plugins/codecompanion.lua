--
-- ~/.config/nvim/lua/plugins/codecompanion.lua
--

-- This configuration is designed for a plugin manager like lazy.nvim.
-- It returns a Lua table that specifies the plugin to be loaded and its configuration.
return {
  -- The GitHub repository for the codecompanion.nvim plugin.
  "olimorris/codecompanion.nvim",

  -- Specifies other plugins that codecompanion.nvim needs to function correctly.
  dependencies = {
    -- plenary.nvim provides common utility functions that are used by many Neovim plugins.
    "nvim-lua/plenary.nvim",
  },

  -- The 'opts' table contains all the user-specific settings for the plugin.
  opts = {
    -- This 'strategies' table sets the DEFAULT AI PROVIDER and MODEL
    -- for different categories of actions within the plugin.
    strategies = {
      -- Configures the default model for running custom prompts.
      cmd = {
        adapter = "ollama",
        model = "llama3.1",
      },

      -- Configures the model for the interactive chat window (:CompanionChat).
      chat = {
        adapter = "ollama",
        model = "llama3.1",
      },

      -- Configures the model for any action that modifies code directly in your buffer
      -- using the 'inline' strategy.
      inline = {
        adapter = "ollama",
        model = "llama3.1",
      },
    },
  },
}
