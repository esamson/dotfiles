nmap("<leader>p", "<Plug>MarkdownPreviewToggle")

vim.g.mkdp_preview_options = {
    uml = {
        server = 'http://localhost:1621',
        imageFormat = 'png'
    },
    sync_scroll_type = 'relative',
    disable_filename = 1
}
