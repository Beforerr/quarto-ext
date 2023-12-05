-- main_findings_to_metadata.lua

-- Flag to indicate if we're under a .main_findings section
local under_main_findings = false

-- Table to store the collected lists under .main_findings headings
local findings_lists = {}

-- This function is called for each Header element in the document
function Header(el)
    if el.classes:includes("main_findings") then
        -- If the header has the .main_findings class, set the flag
        under_main_findings = true
        return {}  -- Remove the heading from the main content
    else
        -- Otherwise, ensure the flag is not set
        under_main_findings = false
    end
end

-- This function is called for each BulletList element in the document
function BulletList(el)
    if under_main_findings then
        -- If under a .main_findings heading, extract text from each list item
        local findings = {}
        for _, item in pairs(el.content) do
            for _, block in pairs(item) do
                if block.t == "Plain" then
                    table.insert(findings, block.content)
                end
            end
        end
        table.insert(findings_lists, findings)
        -- Reset the flag as we've collected the list under the current heading
        under_main_findings = false
        return {} -- Remove the list from the main content
    end
end

-- This function is called for the document's metadata
function Meta(meta)
    if #findings_lists > 0 then
        -- Flatten the findings_lists and add to the metadata
        local flat_findings = {}
        for _, list in ipairs(findings_lists) do
            for _, finding in ipairs(list) do
                table.insert(flat_findings, finding)
            end
        end
        meta['main_findings'] = flat_findings
    end
    meta['output']  = "posterdown::posterdown_betterland"

    return meta
end

return {
    { Header = Header, BulletList = BulletList, Meta = Meta }
}