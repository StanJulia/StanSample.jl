function includeCommand(str)
    if occursin("#include ",str)
        return "#include "
    elseif  occursin("# include ",str)
        return "# include "
    else
        return ""
    end
end

function addFunctions(str,Model)
    inclIDX = findfirst(str,Model)
    srtIDX = inclIDX[end]+1
    while Model[srtIDX] == ' '
        srtIDX+=1
    end
    endIDX = findfirst("\n",Model[srtIDX:end])[1]+srtIDX-2
    filePath = Model[srtIDX:endIDX]
    stream = open(filePath,"r")
    newFunctions = read(stream,String)
    close(stream)
    Model = replace(Model,Model[inclIDX[1]:endIDX]=>"") #Remove path
    return Model[1:inclIDX[1]]*newFunctions*Model[inclIDX[1]+1:end]
end
