def wait_until_loaded(timeout = 30)
  start_time = Time.now
  until (yield)  do
    sleep 0.4
    if (Time.now - start_time) > timeout
      raise RuntimeError, "Timed out after #{timeout} seconds"
    end
  end
end

