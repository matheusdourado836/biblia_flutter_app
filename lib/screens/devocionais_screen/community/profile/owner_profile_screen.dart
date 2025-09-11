import 'dart:ui';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/community/feed_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/devocional_provider.dart';
import '../../../../data/user_provider.dart';
import '../../../../helpers/format_data.dart';
import '../../../../services/bible_service.dart';
import '../../widgets/create_devocional.dart';
import '../../widgets/reject_reason_dialog.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> with TickerProviderStateMixin {
  late final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
  late final userProvider = Provider.of<UserProvider>(context, listen: false);
  late final TabController _tabController = TabController(length: 3, vsync: this);
  MyUser? user;
  ValueNotifier<double> pageHeight = ValueNotifier(460);
  List<Devocional> devocionais = [];
  bool _hasInternetConnection = false;

  Future<void> fetchProfileData() async {
    user = userProvider.currentUser;

    devocionais = await devocionalProvider.getDevocionaisById(id: user!.id!);
    pageHeight.value = setPageHeight();
    return;
  }

  Widget _infoRow(Devocional devocional) {
    if(devocional.status == 0) {
      return Row(
        children: [
          const Text('Visualizações: '),
          Text(formatInfoQuantity(devocional.qtdViews!)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('Público'),
                    Transform.scale(
                      scale: .70,
                      child: Switch(value: devocional.public!, onChanged: (newValue) {
                        devocional.public = newValue;
                        devocionalProvider.updateDevocionalData(devocional.id!, {"public": devocional.public});
                        setState(() {});
                      }),
                    ),
                    InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => DeletePostDialog(
                          currentUser: userProvider.currentUser!,
                          refresh: () => setState(() {}),
                          devocionalId: devocional.id!
                        )
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.red
                        ),
                        child: const Icon(Icons.delete, color: Colors.white,),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => RejectReasonDialog(devocional: devocional)
            ).then((res) {
              if(res ?? false) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido de revisão enviado')));
              }
            }),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Ver motivo')
        ),
        ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DeletePostDialog(
                devocionalId: devocional.id!,
                currentUser: userProvider.currentUser!,
                refresh: () => setState(() {}),
              )
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Row(
              children: [
                Icon(Icons.delete),
                SizedBox(width: 6),
                Text('Excluir'),
              ],
            )
        ),
      ],
    );
  }

  Widget _buildPosts(List<Devocional> devocionais, {int tab = 0}) {
    if(devocionais.isEmpty) {
      String getEmptySectionText() {
        switch(tab) {
          case 0: return 'Você não tem nenhum post aprovado ainda\nQue tal criar um agora?';
          case 1: return 'Você não tem nenhum post esperando ser aprovado ainda';
          case 2: return 'Você não tem nenhum post rejeitado ainda';
          default: return '';
        }
      }
      return Column(
        children: [
          Image.asset('assets/images/no_data.png'),
          Text(
            getEmptySectionText(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center
          ),
        ],
      );
    }
    return ListView.builder(
        itemCount: devocionais.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final devocional = devocionais[index];
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                _infoRow(devocional),
                PostContainer(devocional: devocional),
              ],
            ),
          );
        }
    );
  }

  double setPageHeight() {
    double baseValue = 500.0;
    if(_tabController.index == 0) {
      final devocionaisLength = devocionais.where((d) => d.status == 0).length;
      if(devocionaisLength == 0) return 510;
      return baseValue * devocionaisLength;
    }else if(_tabController.index == 1) {
      final devocionaisLength = devocionais.where((d) => d.status == 1).length;
      if(devocionaisLength == 0) return 510;
      return baseValue * devocionaisLength;
    }else {
      final devocionaisLength = devocionais.where((d) => d.status == 2).length;
      if(devocionaisLength == 0) return 510;
      return baseValue * devocionaisLength;
    }
  }

  Future<void> checkInternetConnection() async {
    _hasInternetConnection = await BibleService().checkInternetConnectivity();
    setState(() => _hasInternetConnection);
    return;
  }

  @override
  void initState() {
    checkInternetConnection();
    _tabController.addListener(() {
      pageHeight.value = setPageHeight();
    });
    super.initState();
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

          return SingleChildScrollView(
            padding: const EdgeInsetsGeometry.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileStatsRow(
                  user: user,
                  devocionais: devocionais
                ),
                const SizedBox(height: 40),
                TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsetsGeometry.symmetric(horizontal: 32),
                  dividerHeight: 0,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_view)),
                    Tab(icon: Icon(CupertinoIcons.clock)),
                    Tab(icon: Icon(Icons.lock_rounded)),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: pageHeight,
                  builder: (context, value, child) {
                    return SizedBox(
                      height: value,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPosts(devocionais.where((d) => d.status == 0).toList(), tab: 0),
                          _buildPosts(devocionais.where((d) => d.status == 1).toList(), tab: 1),
                          _buildPosts(devocionais.where((d) => d.status == 2).toList(), tab: 2),
                        ],
                      ),
                    );
                  }
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: (_hasInternetConnection)
          ? FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: (() => showModalBottomSheet(
          context: context,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          barrierColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          useSafeArea: true,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) => const CreateDevocional()
        )),
        tooltip: 'Adicionar um devocional',
        child: Icon(
          Icons.add,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      )
          : null,
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
              Text(user?.nomeUsuario ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold)),
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