    }
    elsif ($op eq 'copy')
    {
      cell_set($new, "Copy of " . cell_get($cell));
    }
    $last_new_cell = $new;
  }

  # duplicate exactly those links that are from one selected cell to another.
