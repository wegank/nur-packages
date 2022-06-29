{ buildLuarocksPackage
, luaOlder
, luaAtLeast
, fetchgit
, fetchurl
, lua
}:
buildLuarocksPackage {
  pname = "uuid";
  version = "0.3-1";
  knownRockspec = (fetchurl {
    url = "https://luarocks.org/uuid-0.3-1.rockspec";
    sha256 = "1hfs2ydzi2ymnsbgxmybi7j9g3rb3l3zjslxgh07v4v0qs3lxccm";
  }).outPath;
  src = fetchgit (removeAttrs
    (builtins.fromJSON ''{
  "url": "https://github.com/Tieske/uuid.git",
  "rev": "190b336601710efa13ce0f9c85584bc4eef425d0",
  "date": "2021-07-11T09:09:46+02:00",
  "path": "/nix/store/bc8drwldqigpbpq1q61c7z3gqg4b3ka1-uuid",
  "sha256": "1z337d5f6z9hynz94pmsy13aakmgdxwq9a2m9qi4far1hi90czp1",
  "fetchLFS": false,
  "fetchSubmodules": true,
  "deepClone": false,
  "leaveDotGit": false
}
 '') [ "date" "path" ]);

  disabled = with lua; (luaOlder "5.1");
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "https://github.com/Tieske/uuid";
    description = "Generates uuids in pure Lua";
    license.fullName = "Apache 2.0";
  };
}
