-- Function to add all files from a folder to the quickfix list
function AddAllFilesToQuickfix(folder)
  -- Get the list of files in the specified folder
  local files = vim.fn.globpath(folder, '*', 0, 1) -- Get all files in the folder

  if #files == 0 then
    print("No files found in the specified folder!")
    return
  end

  -- Prepare the items for the quickfix list
  local items = {}
  for _, file in ipairs(files) do
    table.insert(items, { filename = file, lnum = 1, text = file })  -- Add each file with line number 1
  end

  -- Set the quickfix list with the prepared items
  vim.fn.setqflist({}, 'a', { title = 'Files from ' .. folder, items = items })
  vim.cmd("copen")  -- Open the quickfix list
end

