macro NDEBUG()
  return false;
end

macro mdebug(message)
  if @NDEBUG()
    return;
  else
    return quote
      warn($message);
    end;
  end
end

macro checkdebug(condition, message)
  if @NDEBUG()
    return;
  else
    return quote
      if !$condition
        warn($message);
      end
    end;
  end
end
