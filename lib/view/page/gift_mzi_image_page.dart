import 'package:flutter_weather/commom_import.dart';

class GiftMziImagePage extends StatefulWidget {
  final MziData data;

  GiftMziImagePage({@required this.data});

  @override
  State createState() => GiftMziImageState();
}

class GiftMziImageState extends PageState<GiftMziImagePage> {
  final _scrollController = ScrollController();
  GiftMziImageViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = GiftMziImageViewModel(data: widget.data)..loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bindErrorStream(_viewModel.error.stream,
        errorText: AppText.of(context).imageSetFail,
        retry: () => _viewModel.loadData());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafKey,
      appBar: CustomAppBar(
        title: Text(
          AppText.of(context).imageSet,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        color: Theme.of(context).accentColor,
        leftBtn: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => pop(context),
        ),
        rightBtns: <Widget>[
          StreamBuilder(
            stream: _viewModel.isFav.stream,
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                onPressed: () => FavHolder().autoFav(widget.data),
              );
            },
          ),
        ],
      ),
      body: LoadingView(
        loadingStream: _viewModel.isLoading.stream,
        child: StreamBuilder(
          stream: _viewModel.data.stream,
          builder: (context, snapshot) {
            final List<MziData> list = snapshot.data ?? [];

            return StreamBuilder(
              stream: _viewModel.dataLength.stream,
              builder: (context, snapshot) {
                final length = snapshot.data ?? 0;

                return RefreshIndicator(
                  onRefresh: () => _viewModel.loadData(),
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: const ClampingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                    itemCount: list.length,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      final data = list[index];
                      final headers = Map<String, String>();
                      headers["Referer"] = data.refer;

                      return GestureDetector(
                        onTap: () => push(context,
                            page: GiftMziWatchPage(
                                index: index,
                                length: length,
                                photos: list,
                                photoStream: _viewModel.photoStream)),
                        child: AspectRatio(
                          aspectRatio: data.width / data.height,
                          child: Hero(
                            tag: "${data.url}${index}true",
                            child: NetImage(
                              headers: headers,
                              url: data.url,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
