class Role {
  final int roleID;
  final String role;
  Role(this.roleID, this.role);
  Map<String, dynamic> get json {
    Map<String, dynamic> map = <String, dynamic>{};
    map['jobtitle'] = role;
    map['type_id'] = roleID;
    return map;
  }

  factory Role.fromMap(Map<String, dynamic> json) {
    return Role(json['type_id'] ?? -1, json['jobtitle'] ?? '');
  }
}
