# MIT License
#
# Copyright (c) 2023 Erik Edin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module SplitMe

function splitme(io::IO, maxbytes::Int)
    nextfileindex = 0
    dir = Base.Filesystem.mktempdir(; cleanup=false)
    println("Files written to $(dir)")
    Base.Filesystem.cd(dir)

    while !eof(io)
        # Read maxbytes bytes from io
        data = read(io, maxbytes)

        name = "$(lpad(nextfileindex, 4, '0')).bin"
        open(name, "w") do newio
            write(newio, data)
        end

        nextfileindex += 1
    end
end

function splitme(path::String, maxbytes::Int)
    open(path, "r") do io
        splitme(io, maxbytes)
    end
end

function unsplitme(partspath::String, outpath::String)
    nextfileindex = 0

    Base.Filesystem.cd(partspath)

    open(outpath, "w") do io
        while true
            name = "$(lpad(nextfileindex, 4, '0')).bin"
            if Base.Filesystem.isfile(name)
                open(name, "r") do partio
                    data = read(partio)
                    write(io, data)
                end
            else
                break
            end
            nextfileindex += 1
        end
    end
end

end # module SplitMe
