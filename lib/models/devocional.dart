class Devocional {
  String? id;
  String? ownerId;
  String? contactEmail;
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
  int? qtdViews;
  bool? public;
  String? rejectReason;

  Devocional(
      {this.id,
      this.ownerId,
      this.contactEmail,
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
      this.qtdViews,
      this.public,
      this.rejectReason
      });

  Devocional.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    contactEmail = json['contactEmail'];
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
    qtdViews = json['qtdViews'];
    public = json["public"];
    rejectReason = json["rejectReason"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['contactEmail'] = contactEmail;
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
    data['qtdViews'] = qtdViews;
    data["public"] = public;
    data["rejectReason"] = rejectReason;
    return data;
  }
}

class Comentario {
  String? id;
  String? autorId;
  String? name;
  String? comment;
  String? createdAt;

  Comentario(
      {this.id,
        required this.name,
      required this.comment,
      required this.createdAt,
      this.autorId,});

  factory Comentario.fromJson(Map<String, dynamic> json) => Comentario(
      id: json["id"],
      autorId: json["autorId"],
      name: json["name"],
      comment: json["comment"],
      createdAt: json["createdAt"]
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["autorId"] = autorId;
    data["name"] = name;
    data["comment"] = comment;
    data["createdAt"] = createdAt;

    return data;
  }
}

class Report {
  String? autor;
  String? comment;
  String? commentId;
  String? devocionalId;
  String? reportReason;
  String? text;
  String? createdAt;

  Report({
    required this.autor,
    required this.comment,
    required this.commentId,
    required this.devocionalId,
    required this.reportReason,
    required this.text,
    required this.createdAt,
  });

  Report.fromJson(Map<String, dynamic> json) {
    autor = json["autor"];
    comment = json["comment"];
    commentId = json["commentId"];
    devocionalId = json["devocionalId"];
    reportReason = json["reportReason"];
    text = json["text"];
    createdAt = json["createdAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["autor"] = autor;
    data["comment"] = comment;
    data["commentId"] = commentId;
    data["devocionalId"] = devocionalId;
    data["reportReason"] = reportReason;
    data["text"] = text;
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
