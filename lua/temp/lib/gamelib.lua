

function handler(self, callback, params_1, params_2)
    return function()
        return callback(self, params_1, params_2)
    end
end