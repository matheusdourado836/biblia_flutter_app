class Devocional {
  String? id;
  String? ownerId;
  String? createdAt;
  String? titulo;
  List<dynamic>? styles;
  String? plainText;
  String? nomeAutor;
  String? bgImagem;
  String? bgImagemUser;
  bool? hasFrost;
  int? status;
  int? qtdComentarios;
  int? qtdCurtidas;
  bool? public;

  Devocional(
      {this.id,
      this.ownerId,
      this.createdAt,
      this.titulo,
      this.styles,
      this.plainText,
      this.nomeAutor,
      this.bgImagem,
      this.bgImagemUser,
      this.hasFrost,
      this.status,
      this.qtdComentarios,
      this.qtdCurtidas,
      this.public});

  Devocional.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    createdAt = json['createdAt'];
    titulo = json['titulo'];
    styles = json['styles'];
    plainText = json['plainText'];
    nomeAutor = json['nomeAutor'];
    bgImagem = json['bgImagem'];
    bgImagemUser = json['bgImagemUser'];
    hasFrost = json['hasFrost'];
    status = json['status'];
    qtdComentarios = json['qtdComentarios'];
    qtdCurtidas = json['qtdCurtidas'];
    public = json["public"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['createdAt'] = createdAt;
    data['titulo'] = titulo;
    data['styles'] = styles;
    data['plainText'] = plainText;
    data['bgImagem'] = bgImagem;
    data['nomeAutor'] = nomeAutor;
    data['bgImagemUser'] = bgImagemUser;
    data['hasFrost'] = hasFrost;
    data['status'] = status;
    data['qtdComentarios'] = qtdComentarios;
    data['qtdCurtidas'] = qtdCurtidas;
    data["public"] = public;
    return data;
  }
}

class Comentario {
  String? id;
  String? name;
  String? comment;
  int qtdCurtidas;
  String? createdAt;

  Comentario(
      {required this.name,
      required this.comment,
      required this.qtdCurtidas,
      required this.createdAt,
      this.id,});

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
      id: json["id"],
      name: json["name"],
      comment: json["comment"],
      qtdCurtidas: json["qtdCurtidas"],
      createdAt: json["createdAt"]
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["comment"] = comment;
    data["qtdCurtidas"] = qtdCurtidas;
    data["createdAt"] = createdAt;

    return data;
  }
}

class ThematicDevocional {
  String? id;
  String? createdAt;
  String? referencia;
  String? passagem;
  String? titulo;
  String? texto;
  String? nomeAutor;
  String? bgImagem;

  ThematicDevocional(
      {this.id,
      this.createdAt,
      this.referencia,
      this.passagem,
      this.titulo,
      this.texto,
      this.nomeAutor,
      this.bgImagem});

  ThematicDevocional.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    referencia = json['referencia'];
    passagem = json['passagem'];
    titulo = json['titulo'];
    texto = json['texto'];
    nomeAutor = json['nomeAutor'];
    bgImagem = json['bgImagem'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['referencia'] = referencia;
    data['passagem'] = passagem;
    data['titulo'] = titulo;
    data['texto'] = texto;
    data['bgImagem'] = bgImagem;
    data['nomeAutor'] = nomeAutor;
    return data;
  }
}