--[[
  
  Copyright (C) 2015 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
   
  api/folder.lua
  lua-dropbox
  
  Created by Masatoshi Teruya on 15/03/11.
  
--]]
-- module
local normalize = require('path').normalize;
local createEntry = require('dropbox.util').createEntry;
-- class
local Folder = require('halo').class.Folder;


Folder.inherits {
    'dropbox.api.common.Common'
};


function Folder:init( cli, entry )
    local own = protected( self );
    
    own.cli = cli;
    own.path = entry.path;
    -- have contents
    if entry.contents then
        local contents = {};
        
        for idx, entry in ipairs( entry.contents ) do
            contents[idx] = createEntry( own.cli, entry );
        end
        entry.contents = contents;
    end
    
    -- set properties
    for k, v in pairs( entry ) do
        rawset( self, k, v );
    end

    return self;
end


-- https://www.dropbox.com/developers/core/docs#metadata
function Folder:metadata( qry, opts )
    local own = protected( self );
    local res, err = own.cli:get(
        '/metadata/auto/' .. own.path, qry, nil, opts
    );
    
    if res and res.status == 200 then
        if not res.body.is_dir then
            return createEntry( own.cli, res.body );
        -- have contents
        elseif res.body.contents then
            local contents = {};
            
            for idx, entry in ipairs( res.body.contents ) do
                contents[idx] = createEntry( own.cli, entry );
            end
            res.body.contents = contents;
        end
        
        -- update self properties
        for k, v in pairs( res.body ) do
            rawset( self, k, v );
        end
    end
    
    return self;
end


-- https://www.dropbox.com/developers/core/docs#search
function Folder:search( qry, opts )
    local own = protected( self );
    local res, err = own.cli:get(
        '/search/auto/' .. own.path, qry, nil, opts
    );
    
    return res, err;
end


-- The path to the new folder to create relative to folder path
-- https://www.dropbox.com/developers/core/docs#fileops-create-folder
function Folder:createFolder( path, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/create_folder', nil, {
        root = 'auto',
        path = normalize( own.path, path );
    }, opts );
    
    if res and res.status == 200 then
        res.body = createEntry( own.cli, res.body );
    end
    
    return res, err;
end


return Folder.exports;
