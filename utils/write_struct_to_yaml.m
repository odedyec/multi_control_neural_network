function write_struct_to_yaml(config_struct, filename)
%WRITE_STRUCT_TO_YAML Summary of this function goes here
%   Detailed explanation goes here

f = fopen(filename, 'w');
fn = fieldnames(config_struct);
for k=1:numel(fn)
    if( isnumeric(config_struct.(fn{k})) )
        if length(config_struct.(fn{k})) > 1  % array
            s = sprintf('%s:\n', fn{k});
            fwrite(f, s);
            for v=config_struct.(fn{k})
                s = sprintf('- %d\n', v);
                fwrite(f, s);
            end
        else  % numbers
            s = sprintf('%s: %d\n', fn{k}, config_struct.(fn{k}));
            fwrite(f, s);
        end
    end
end
fclose(f);
end

