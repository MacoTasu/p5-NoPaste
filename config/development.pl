+{
    database => [
        "dbi:mysql:database=no_paste;host=localhost;port=3306", "root", "", {
            RaiseError           => 1,
            PrintError           => 0,
            AutoInactiveDestroy  => 1,
            mysql_enable_utf8    => 1,
            mysql_auto_reconnect => 1,
        },
    ]
};
