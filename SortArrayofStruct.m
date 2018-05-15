function outStructArray = SortArrayofStruct( structArray, fieldName )
%% Reversely sort the structArray according to the field.
%
% Author: Yusen Fan, ysfan@umd.edu
    
    
    if ( ~isempty(structArray) )
      if(strcmp(fieldName,'BoundingBox'))
          [~,I] = sort(arrayfun (@(x) x.(fieldName)(3)*x.(fieldName)(4),...
              structArray),'descend') ;
      else
          [~,I] = sort(arrayfun (@(x) x.(fieldName), structArray),'descend') ;
      end
      outStructArray = structArray(I) ;        
    else 
        disp ('Array of struct is empty');
    end      
end
% sort(A,'descend')