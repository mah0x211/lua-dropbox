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
   
  api/fileops.lua
  lua-dropbox
  
  Created by Masatoshi Teruya on 15/03/11.
  
--]]
-- modules
local createEntry = require('dropbox.util').createEntry;
-- class
local FileOps = require('halo').class.FileOps;


FileOps.inherits {
    'dropbox.unchangeable.Unchangeable'
};


function FileOps:init( cli )
    protected(self).cli = cli;
    return self;
end


-- https://www.dropbox.com/developers/core/docs#fileops-copy
function FileOps:copy( src, dst, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/copy', {
        root = 'auto',
        from_path = src,
        to_path = dst
    }, nil, opts );
    
    if res and res.status == 200 then
        return createEntry( own.cli, res.body );
    end
    
    return res, err;
end


-- https://www.dropbox.com/developers/core/docs#fileops-copy
function FileOps:copyByRef( ref, dst, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/copy', {
        root = 'auto',
        from_copy_ref = ref,
        to_path = dst
    }, nil, opts );
    
    if res and res.status == 200 then
        return createEntry( own.cli, res.body );
    end
    
    return res, err;
end


-- https://www.dropbox.com/developers/core/docs#fileops-create-folder
function FileOps:createFolder( path, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/create_folder', {
        root = 'auto',
        path = path
    }, nil, opts );
    
    if res and res.status == 200 then
        res.body = createEntry( own.cli, res.body );
    end
    
    return res, err;
end


-- https://www.dropbox.com/developers/core/docs#fileops-delete
function FileOps:delete( path, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/delete', {
        root = 'auto',
        path = path
    }, nil, opts );
    
    if res and res.status == 200 then
        res.body = createEntry( own.cli, res.body );
    end
    
    return res, err;
end


-- https://www.dropbox.com/developers/core/docs#fileops-move
function FileOps:move( src, dst, opts )
    local own = protected(self);
    local res, err = own.cli:post( '/fileops/move', {
        root = 'auto',
        from_path = src,
        to_path = dst
    }, nil, opts );
    
    if res and res.status == 200 then
        res.body = createEntry( own.cli, res.body );
    end
    
    return res, err;
end


return FileOps.exports;
