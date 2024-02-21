return {
  -- https://github.com/ojroques/nvim-osc52/issues/30#issuecomment-1884539441
  "ojroques/nvim-osc52",
  keys = {
    {
      "<leader>y",
      function()
        return require("osc52").copy_operator()
      end, -- <-- previously I wasn't using a return statement here
      desc = "copy motion",
      expr = true,
    },
    {
      "<leader>Y",
      "<leader>y_",
      remap = true,
      desc = "copy line",
    },
    {
      mode = "v",
      "<leader>y",
      function()
        require("osc52").copy_visual()
      end,
      desc = "copy selection",
    },
  },
}
