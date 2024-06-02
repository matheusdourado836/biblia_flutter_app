class Devocional {
  String? id;
  String? createdAt;
  String? referencia;
  String? titulo;
  String? texto;
  int? textAlign;
  String? nomeAutor;
  String? bgImagem;
  String? bgImagemUser;
  int? status;
  int? qtdComentarios;
  int? qtdCurtidas;
  bool? public;

  Devocional(
      {this.id,
        this.createdAt,
        this.referencia,
        this.titulo,
        this.texto,
        this.textAlign,
        this.nomeAutor,
        this.bgImagem,
        this.bgImagemUser,
        this.status,
        this.qtdComentarios,
        this.qtdCurtidas,
        this.public}
  );

  Devocional.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    referencia = json['referencia'];
    titulo = json['titulo'];
    texto = json['texto'];
    textAlign = json['textAlign'];
    nomeAutor = json['nomeAutor'];
    bgImagem = json['bgImagem'];
    bgImagemUser = json['bgImagemUser'];
    status = json['status'];
    qtdComentarios = json['qtdComentarios'];
    qtdCurtidas = json['qtdCurtidas'];
    public = json["public"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['referencia'] = referencia;
    data['titulo'] = titulo;
    data['texto'] = texto;
    data['textAlign'] = textAlign;
    data['bgImagem'] = bgImagem;
    data['nomeAutor'] = nomeAutor;
    data['bgImagemUser'] = bgImagemUser;
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

  Comentario({required this.name, required this.comment, required this.qtdCurtidas, this.id});

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(id: json["id"], name: json["name"], comment: json["comment"], qtdCurtidas: json["qtdCurtidas"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["comment"] = comment;
    data["qtdCurtidas"] = qtdCurtidas;

    return data;
  }
}