import 'dart:ui';

import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/community/feed_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/devocional_provider.dart';
import '../../../../data/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  MyUser? user;

  Future<List<Devocional>> fetchProfileData() async {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    user = await userProvider.getUserById(id: widget.userId);
    final devocionais = await devocionalProvider.getDevocionaisById(id: widget.userId);

    return devocionais.where((d) => d.status == 0 && d.public == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
        future: fetchProfileData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados do perfil: ${snapshot.error}'));
          }

          final devocionais = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileStatsRow(
                  user: user,
                  devocionais: devocionais
                ),
                const SizedBox(height: 40),
                ListView.builder(
                    itemCount: devocionais.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final devocional = devocionais[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: PostContainer(devocional: devocional),
                      );
                    }
                )
              ],
            ),
          );
        }
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  final MyUser? user;
  final List<Devocional> devocionais;
  const _ProfileStatsRow({required this.user, required this.devocionais});

  @override
  Widget build(BuildContext context) {
    final qtdPosts = devocionais.length;
    final qtdCurtidas = devocionais.fold(0, (previousValue, devocional) => previousValue + (devocional.qtdCurtidas ?? 0));
    final qtdVisualizacoes = devocionais.fold(0, (previousValue, devocional) => previousValue + (devocional.qtdViews ?? 0));

    return Row(
      children: [
        InkWell(
          onTap: () => showDialog(
            context: context,
            useSafeArea: false,
            builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black.withValues(alpha: .2),
                    alignment: Alignment.center,
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(500),
                        border: Border.all(),
                        image: DecorationImage(
                          filterQuality: FilterQuality.high,
                          image: CachedNetworkImageProvider(
                            user?.profilePhotoUrl ?? '',
                            errorListener: (error) => const NoBgUser()
                          ),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                  ),
                ),
              ),
            )
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(100),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundImage: CachedNetworkImageProvider(
                user?.profilePhotoUrl ?? '',
                errorListener: (error) => const NoBgUser()
              ),
              onBackgroundImageError: (_, __) => const NoBgUser(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.nomeUsuario ?? 'sem nome', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(qtdPosts.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('posts', style: TextStyle(fontSize: 12))
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(qtdCurtidas.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('curtidas', style: TextStyle(fontSize: 12))
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(qtdVisualizacoes.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('visualizações', style: TextStyle(fontSize: 12))
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
