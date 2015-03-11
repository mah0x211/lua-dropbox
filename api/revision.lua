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
   
  api/revision.lua
  lua-dropbox
  
  Created by Masatoshi Teruya on 15/03/11.
  
--]]
-- modules
local createEntry = require('dropbox.util').createEntry;
-- class
local Revision = require('halo').class.Revision;


Revision.inherits {
    'dropbox.unchangeable.Unchangeable'
};


function Revision:init( cli, entry )
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


-- https://www.dropbox.com/developers/core/docs#restore
function Revision:restore( opts )
    local own = protected( self );
    local res, err = own.cli:post(
        '/restore/auto/' .. own.path, { rev = own.rev }, nil, opts
    );
    
    if res and res.status == 200 then
        return createEntry( own.cli, res.body );
    end
    
    return res, err;
end




return Revision.exports;
