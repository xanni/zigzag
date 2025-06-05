    if (/^#/)
    {
      db_sync();
      $Command_Count = 0;   # Write cached data to file
      eval;
