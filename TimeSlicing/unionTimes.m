function result = unionTimes(varargin)
% This function unions two sets of time inclusion ranges

    result = varargin{1};
    
    for i = 2:numel(varargin)
        result = union(result,varargin{i});
    end

    
    %% Helper Function: intersect()
    function result = union(a,b)
        % Author Ryan Y
        % Handles an intersection between two inclusion period lists
        
        c = [a; b];
        
        operations = true;
        while operations % if no operations carried out for one execution, quit
            
            % Prepare by sorting based on starts and setting operation
            % counter to 0
            c = sortrows(c,1);
            operations = 0;
            
            for j = 1:(size(c,1) - 1)

                if isequal(c(j,:),[NaN NaN])
                    continue;
                end

                if c(j,2) >= c(j+1,1)
                    c(j,:) = [min(c(j,1),c(j+1,1)), max(c(j,2),c(j+1,2))];
                    c(j+1,:) = [NaN NaN];
                    operations = operations + 1;
                end

                % Probably unecessary for the time union function (whereas it
                % is necessary for the intersection function)
                if c(j,1) > c(j,2)
                    c(j,:) = [NaN NaN];
                    operations = operations + 1;
                end
            end
            
            % Delete all nullified entires
            c( logical(sum(isnan(c),2)), :) = [];
            
        end
        
        
        
        % Return result
        result = c;
    end
    
end