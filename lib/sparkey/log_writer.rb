class Sparkey::LogWriter
  include Sparkey::Errors

  def create(filename, compression, block_size)
    ptr = FFI::MemoryPointer.new(:pointer)
    log_filename = "#{filename}.spl"

    handle_status Sparkey::Native.logwriter_create(ptr, log_filename, compression, block_size)

    @log_writer_ptr = ptr.read_pointer
  end

  def open(filename)
    ptr = FFI::MemoryPointer.new(:pointer)
    log_filename = "#{filename}.spl"

    handle_status Sparkey::Native.logwriter_append(ptr, log_filename)
    @log_writer_ptr = ptr.read_pointer
  end

  def put(key, value)
    key_length = key.bytesize
    key_ptr = FFI::MemoryPointer.new(:uint8, key_length).write_bytes(key)

    value_length = value.bytesize
    value_ptr = FFI::MemoryPointer.new(:uint8, value_length).write_bytes(value)

    handle_status Sparkey::Native.logwriter_put(@log_writer_ptr, key_length, key_ptr, value_length, value_ptr)
  end

  def delete(key)
    key_length = key.bytesize
    key_ptr = FFI::MemoryPointer.new(:uint8, key_length).write_bytes(key)

    handle_status Sparkey::Native.logwriter_delete(@log_writer_ptr, key_length, key_ptr)
  end

  def flush
    handle_status Sparkey::Native.logwriter_flush(@log_writer_ptr)
  end

  def close
    ptr = FFI::MemoryPointer.new(:pointer).write_pointer(@log_writer_ptr)

    Sparkey::Native.logwriter_close(ptr)
  end
end
