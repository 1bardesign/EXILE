function newPaddedImage(filename)
    local source = love.image.newImageData(filename);
    local w, h = source:getWidth(), source:getHeight();
   
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/math.log(2)));
    local hp = math.pow(2, math.ceil(math.log(h)/math.log(2)));
   
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp);
        padded:paste(source, 0, 0);
        return love.graphics.newImage(padded);
    end
	source = love.graphics.newImage(source);
	source:setFilter( "nearest", "nearest" ); --keep scaling all nice and pixely
    return source
end
