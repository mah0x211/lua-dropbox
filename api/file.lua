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
   
  api/file.lua
  lua-dropbox
  
  Created by Masatoshi Teruya on 15/03/11.
  
--]]
-- modules
local createEntry = require('dropbox.util').createEntry;
local Revision = require('dropbox.api.revision');
-- constants
local API_CONTENT_URI = 'https://api-content.dropbox.com/1';
-- class
local File = require('halo').class.File;


File.inherits {
    'dropbox.api.common.Common'
};


function File:init( cli, entry )
    local own = protected( self );
    
    own.cli = cli;
    own.path = entry.path;
    own.rev = entry.rev;
    -- set properties
    for k, v in pairs( entry ) do
        rawset( self, k, v );
    end

    return self;
end


-- https://www.dropbox.com/developers/core/docs#files-GET
function File:get( opts )
    local own = protected(self);
    return own.cli:get(
        '/files/auto/' .. own.path, { rev = own.rev }, nil, opts,
        API_CONTENT_URI
    );
end


--[[ TODO: should implements a multipart/form-data encoder
-- https://www.dropbox.com/developers/core/docs#files_put
function File:put( path, qry, body, opts )
    return protected(self).cli:post(
        '/files_put/auto/' .. tostring( path ), qry, body, opts, API_CONTENT_URI
    );
end
--]]


-- https://www.dropbox.com/developers/core/docs#metadata
function File:metadata( qry, opts )
    local own = protected( self );
    local res, err = own.cli:get(
        '/metadata/auto/' .. own.path, qry, nil, opts
    );
    
    -- update property
    if res and res.status == 200 then
        -- change to directory
        if res.body.is_dir then
            return createEntry( own.cli, res.body );
        end
        
        -- update self properties
        for k, v in pairs( res.body ) do
            rawset( self, k, v );
        end
    end
    
    return self;
end


-- https://www.dropbox.com/developers/core/docs#revisions
function File:revisions( qry, opts )
    local own = protected( self );
    local res, err = own.cli:get(
        '/revisions/auto/' .. own.path, qry, nil, opts
    );
    
    if res and res.status == 200 then
        local revisions = {};
        
        for idx, entry in ipairs( res.body ) do
          revisions[idx] = Revision.new( own.cli, entry );
        end
        
        res.body = revisions;
    end
    
    return res, err;
end


-- https://www.dropbox.com/developers/core/docs#media
function File:media( opts )
    local own = protected( self );
    return own.cli:post(
        '/media/auto/' .. own.path, nil, nil, opts
    );
end


-- https://www.dropbox.com/developers/core/docs#copy_ref
function File:copyref( opts )
    local own = protected( self );
    return own.cli:get(
        '/copy_ref/auto/' .. own.path, nil, nil, opts
    );
end


-- https://www.dropbox.com/developers/core/docs#thumbnails
function File:thumbnail( qry, opts )
    local own = protected( self );
    return own.cli:get(
        '/thumbnails/auto/' .. own.path, qry, nil, opts, API_CONTENT_URI
    );
end


-- https://www.dropbox.com/developers/core/docs#previews
function File:preview( opts )
    local own = protected( self );
    return own.cli:get(
        '/previews/auto/' .. own.path, {
            rev = own.rev
        }, nil, opts, API_CONTENT_URI
    );
end


return File.exports;
