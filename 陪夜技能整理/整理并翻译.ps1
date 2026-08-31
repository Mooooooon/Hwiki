$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$rawPath = Join-Path $here '陪夜技能_原始数据.csv'
$sourcePath = Join-Path $here '启用技能ID来源.csv'

if (-not (Test-Path -LiteralPath $rawPath)) {
    throw "缺少原始数据文件：$rawPath"
}

$categoryMap = [ordered]@{
    '淫欲'    = '情欲与常规性交'
    '奉仕'    = '侍奉与口手服务'
    'M性'     = '受虐与拘束SM'
    '詰られ'  = '女方主导与责骂'
    '変態'    = '特殊癖好与公开玩法'
    '交換'    = '换伴与寝取让渡'
    '乱交'    = '多人乱交'
    'ハーレム' = '后宫与女性多人'
}

# 按从长到短的顺序替换，尽量保留原名称中的情境、动作与姿势信息。
$nameRules = @(
    @('逆アナル四つん這いバイブ責め', '逆向肛交跪趴式震动棒刺激'),
    @('逆アナル正常位', '逆向肛交传教士位'),
    @('セックスソファーまんぐり返しアナルセックス', '沙发翻腿蜷曲式肛交'),
    @('セックスソファーまんぐり返しセックス', '沙发翻腿蜷曲式性交'),
    @('スワッピングアナルセックス', '换伴肛交'),
    @('スワッピングセックス', '换伴性交'),
    @('アナル処女喪失セックス', '初次肛交'),
    @('処女喪失セックス', '初次性交'),
    @('アナルバイブオナニー', '肛门震动棒自慰'),
    @('ディルドアナルオナニー', '假阳具肛门自慰'),
    @('ディルドボックスオナニー', '假阳具箱式自慰'),
    @('ディルドオナニー', '假阳具自慰'),
    @('両穴バイブオナニー', '双穴震动棒自慰'),
    @('バイブオナニー', '震动棒自慰'),
    @('アナルオナニー', '肛门自慰'),
    @('手コキオナニー', '手部刺激配合自慰'),
    @('フェラオナニー', '口交配合自慰'),
    @('アナルセックス', '肛交'),
    @('だいしゅきホールド', '紧抱夹腰式'),
    @('グラインド', '磨蹭式'),
    @('まんぐり返し', '翻腿蜷曲式'),
    @('まんぐり', '翻腿蜷曲式'),
    @('寄り添い側位', '贴身侧卧位'),
    @('腕持ち後背位', '持臂后入位'),
    @('手繋ぎ対面騎乗位', '牵手面对面骑乘位'),
    @('手繋ぎ騎乗位', '牵手骑乘位'),
    @('挟み込みアナル騎乗位', '夹持式肛门骑乘位'),
    @('挟み込み騎乗位', '夹持式骑乘位'),
    @('アナル背面騎乗位', '背向肛门骑乘位'),
    @('背面アナル騎乗位', '背向肛门骑乘位'),
    @('背面騎乗位', '背向骑乘位'),
    @('対面アナル騎乗位', '面对面肛门骑乘位'),
    @('対面騎乗位', '面对面骑乘位'),
    @('アナル騎乗位', '肛门骑乘位'),
    @('騎乗位', '骑乘位'),
    @('背面アナル駅弁', '背向抱持式肛交'),
    @('背面駅弁', '背向站立抱持位'),
    @('対面アナル駅弁', '面对面抱持式肛交'),
    @('対面駅弁', '面对面站立抱持位'),
    @('駅弁', '站立抱持位'),
    @('アナル背面立位', '背向站立肛交'),
    @('背面アナル立位', '背向站立肛交'),
    @('背面立位', '背向站立位'),
    @('アナル立位', '站立肛交'),
    @('立位', '站立位'),
    @('立ち後背位', '站立后入位'),
    @('膝立ちアナルセックス後背位', '跪姿后入肛交'),
    @('膝立ちセックス後背位', '跪姿后入性交'),
    @('膝立ち後背位', '跪姿后入位'),
    @('アナルセックス後背位', '后入式肛交'),
    @('セックス後背位', '后入式性交'),
    @('アナル後背位', '后入式肛交'),
    @('後背位', '后入位'),
    @('らぶらぶアナル寝バック', '甜蜜俯卧后入肛交'),
    @('らぶらぶ寝バック', '甜蜜俯卧后入性交'),
    @('寝バック', '俯卧后入位'),
    @('アナルセックス正常位', '传教士位肛交'),
    @('セックス正常位', '传教士位性交'),
    @('アナル正常位', '传教士位肛交'),
    @('ディープアナル正常位', '深插传教士位肛交'),
    @('ディープ正常位', '深插传教士位性交'),
    @('正常位', '传教士位'),
    @('アナルセックス側位', '侧卧位肛交'),
    @('セックス側位', '侧卧位性交'),
    @('台上側位', '台上侧卧位'),
    @('側位', '侧卧位'),
    @('抱え込みアナル座位', '抱腿坐姿肛交'),
    @('抱え込み座位', '抱腿坐姿'),
    @('アナル対面座位', '面对面坐姿肛交'),
    @('対面アナル座位', '面对面坐姿肛交'),
    @('対面座位', '面对面坐姿'),
    @('背面座位', '背向坐姿'),
    @('松葉崩しアナルセックス', '松叶崩式肛交'),
    @('松葉崩しセックス', '松叶崩式性交'),
    @('松葉崩し', '松叶崩式'),
    @('抱えM字', '抱持M字开腿位'),
    @('M字開脚', 'M字开腿'),
    @('ブリッジアナルセックス', '桥式肛交'),
    @('ブリッジセックス', '桥式性交'),
    @('ブリッジ', '桥式'),
    @('四つん這い', '跪趴式'),
    @('テーブル後背位', '桌面后入位'),
    @('台上アナルセックス', '台上肛交'),
    @('台上セックス', '台上性交'),
    @('台上', '台上'),
    @('ベッドアナル', '床上肛门'),
    @('ベッド', '床上'),
    @('ソファーアナル', '沙发肛门'),
    @('ソファー', '沙发'),
    @('風呂', '浴室'),
    @('トイレ', '厕所'),
    @('スケベ椅子アナルセックス', '情趣椅肛交'),
    @('スケベ椅子セックス', '情趣椅性交'),
    @('スケベ椅子フェラ', '情趣椅口交'),
    @('椅子アナル', '椅上肛门'),
    @('椅子', '椅上'),
    @('イラマチオ', '深喉口交'),
    @('セルフイラマ', '自主深喉口交'),
    @('ディープスロート', '深喉口交'),
    @('フェラチオ', '口交'),
    @('フェラ', '口交'),
    @('パイズリ', '乳交'),
    @('手コキ', '手部刺激'),
    @('足コキ', '足部刺激'),
    @('オナホコキ', '模拟自慰器夹弄'),
    @('逆アナル', '逆向肛交'),
    @('シックスナイン', '69式'),
    @('クンニ', '舔阴'),
    @('貝合わせ', '女女性器摩擦'),
    @('玉舐め', '舔睾丸'),
    @('尻舐め', '舔臀与肛周'),
    @('アナル舐め', '舔肛'),
    @('全身舐め', '全身舔舐'),
    @('高級MP全身洗い', '高级泡泡浴全身清洗'),
    @('MP全身洗い', '泡泡浴全身清洗'),
    @('高級マットプレイ', '高级垫式泡泡浴玩法'),
    @('洗い', '泡泡浴清洗'),
    @('太バイブ', '粗震动棒'),
    @('双頭バイブ', '双头震动棒'),
    @('両穴バイブ', '双穴震动棒'),
    @('アナルバイブ', '肛门震动棒'),
    @('バイブ', '震动棒'),
    @('ディルド', '假阳具'),
    @('電マ', '电动按摩棒'),
    @('オナニー', '自慰'),
    @('愛撫', '爱抚'),
    @('オナホ', '自慰器'),
    @('セックス', '性交'),
    @('アナル', '肛门'),
    @('スワッピング', '换伴'),
    @('寝取らせ', '主动让伴侣与他人发生关系'),
    @('報告_', '事后报告·'),
    @('乱交', '多人乱交'),
    @('ハーレム', '后宫'),
    @('ダブル', '双人'),
    @('百合', '女性同性'),
    @('3P', '3P'),
    @('３P', '3P'),
    @('4P', '4P'),
    @('２穴', '双穴'),
    @('2穴', '双穴'),
    @('両穴', '双穴'),
    @('処女', '处女'),
    @('バージン', '初次'),
    @('酔い', '醉酒'),
    @('媚薬', '媚药'),
    @('目隠し', '蒙眼'),
    @('拘束', '束缚'),
    @('吊るし', '悬吊'),
    @('三角木馬', '三角木马'),
    @('木馬', '木马'),
    @('ギロチン', '断头台架'),
    @('首絞め', '掐颈'),
    @('バラ鞭', '蔷薇鞭'),
    @('お仕置き', '惩罚'),
    @('失禁', '失禁'),
    @('ロウ', '滴蜡'),
    @('ムチ', '鞭打'),
    @('罵倒', '辱骂'),
    @('羞恥責め', '羞耻调教'),
    @('快楽責め', '快感调教'),
    @('被虐責め', '受虐调教'),
    @('調教', '调教'),
    @('乱暴', '粗暴'),
    @('辱め', '羞辱'),
    @('露出', '露出'),
    @('公開', '公开'),
    @('衆人環視', '众人围观'),
    @('ハメ撮り', '性交录像'),
    @('AV撮影', '成人视频拍摄'),
    @('変態', '特殊癖好'),
    @('敏感なクリトリス', '敏感阴蒂'),
    @('中出し大好き', '非常喜欢内射'),
    @('お尻中出し大好き', '非常喜欢肛内射精'),
    @('いじられ好き', '喜欢被玩弄'),
    @('大好き', '非常喜欢'),
    @('の素質', '的资质'),
    @('がご褒美', '即奖励'),
    @('告白', '告白'),
    @('言いなり', '言听计从'),
    @('従順', '顺从'),
    @('従属', '从属'),
    @('隷属', '隶属'),
    @('服従', '服从'),
    @('逆転', '主从逆转'),
    @('主従', '主从'),
    @('女王様', '女王'),
    @('王女様', '公主殿下'),
    @('小悪魔', '小恶魔'),
    @('メスガキ', '雌小鬼式挑衅'),
    @('いじめっ子', '欺负者'),
    @('詰られ', '受责骂'),
    @('説教', '训诫'),
    @('詰り', '责骂'),
    @('責め', '刺激'),
    @('反論封印', '禁止反驳'),
    @('語らせ', '边讲述边'),
    @('実況', '实况讲述'),
    @('淫語', '淫语'),
    @('言葉責め', '言语挑逗'),
    @('欲望開放', '释放欲望'),
    @('ドキドキ', '紧张刺激'),
    @('ハード', '强烈'),
    @('覚醒', '觉醒'),
    @('甘えん坊', '爱撒娇'),
    @('甘え', '撒娇'),
    @('甘やかし', '宠溺'),
    @('献身', '献身'),
    @('イチャイチャ', '亲昵'),
    @('癒し', '治愈'),
    @('熟練', '熟练'),
    @('わがまま', '任性'),
    @('ラブ奉仕', '爱意服务'),
    @('ラブ', '爱意'),
    @('上級奉仕', '高级服务'),
    @('ソープ奉仕', '泡泡浴服务'),
    @('奉仕', '服务'),
    @('連続射精種付け', '连续内射受孕'),
    @('連続種付け', '连续内射受孕'),
    @('連続尻穴射精', '连续肛内射精'),
    @('種付け', '受孕式内射'),
    @('大量射精', '大量射精'),
    @('孕ませ', '受孕'),
    @('中出し', '内射'),
    @('ごっくん', '吞咽'),
    @('お掃除', '清理式'),
    @('おねだり', '撒娇请求'),
    @('桃色泡姫', '粉红泡姬'),
    @('肉食', '主动贪欲'),
    @('卑猥', '淫秽'),
    @('欲情', '情欲'),
    @('らぶらぶ', '甜蜜'),
    @('母性', '母性'),
    @('激甘ラブ', '超甜蜜爱恋'),
    @('結婚', '婚后'),
    @('愛奴', '爱奴'),
    @('退行', '退行角色扮演'),
    @('犬プレイ', '宠物犬角色扮演'),
    @('わんちゃんプレイ', '小狗角色扮演'),
    @('Ｈなポーズ', '情趣姿势'),
    @('ポーズプレイ', '姿势展示玩法'),
    @('ポーズ', '姿势'),
    @('プレイ', '玩法'),
    @('嬲り', '多人玩弄'),
    @('ビッチ', '淫荡'),
    @('抵抗', '反抗演出'),
    @('押さえつけ', '压制'),
    @('見せつけ', '展示给旁人'),
    @('ヤキモチ', '吃醋'),
    @('抱きつき', '从后相拥'),
    @('腕持ち', '持臂'),
    @('頭掴み', '抓头'),
    @('抱え', '抱持'),
    @('密着', '紧贴'),
    @('重ね', '叠身'),
    @('立ち', '站姿'),
    @('寄り添い', '贴身'),
    @('テーブル', '桌面'),
    @('ディープ', '深度'),
    @('リード', '主导'),
    @('スケベ', '情趣'),
    @('キス', '接吻'),
    @('お部屋', '房间'),
    @('お風呂', '浴室'),
    @('お浴室', '浴室'),
    @('お尻', '臀部'),
    @('見下し', '轻蔑'),
    @('全身', '全身'),
    @('連続', '连续'),
    @('愛玩奴隷', '玩物奴隶'),
    @('M豚', 'M猪'),
    @('ドM', '重度受虐'),
    @('ドS', '重度施虐'),
    @('美希達と', '与美希等人'),
    @('美希に', '与美希'),
    @('千里達と', '与千里等人'),
    @('千里に', '与千里'),
    @('はるの達と', '与春乃等人'),
    @('はるのに', '与春乃'),
    @('おもらし', '漏尿'),
    @('お漏らし', '漏尿'),
    @('嬌声', '娇声'),
    @('邪淫', '淫乱'),
    @('全身', '全身'),
    @('&', '＋'),
    @('＆', '＋'),
    @('_', '·')
)

function Convert-SkillName([string]$name) {
    $result = $name
    foreach ($rule in $nameRules) {
        $result = $result.Replace($rule[0], $rule[1])
    }
    $result = $result.Replace('【', '【').Replace('】', '】')
    $result = $result -replace '達と', '等人'
    $result = $result -replace 'に换伴', '换伴'
    $result = $result -replace '性交性交', '性交'
    $result = $result -replace '肛门肛交', '肛交'
    $result = $result -replace '肛门肛门', '肛门'
    $result = $result -replace '断头台架台', '断头台架'
    $result = $result -replace '言葉刺激', '语言挑逗'
    $result = $result -replace '体質', '体质'
    $result = $result -replace '潜望鏡', '潜望镜式'
    $result = $result -replace '忠実', '忠诚'
    $result = $result -replace '対面', '面对面'
    $result = $result -replace '顔面', '颜面'
    $result = $result -replace '主从主从逆转', '主从逆转'
    $result = $result -replace '站站立位', '站立位'
    $result = $result -replace '膝站立', '跪姿'
    $result = $result -replace '後侧卧位', '后侧卧位'
    $result = $result -replace '性交后侧卧位', '后侧卧位性交'
    $result = $result -replace '肛交后侧卧位', '后侧卧位肛交'
    $result = $result -replace '太震动棒', '粗震动棒'
    $result = $result -replace '忠宠物犬角色扮演', '忠犬角色扮演'
    $result = $result -replace '性交沙发后入位', '沙发后入式性交'
    $result = $result -replace '性交沙发后入式肛交', '沙发后入式肛交'
    $result = $result -replace '肛门桌面后入位', '桌面后入式肛交'
    $result = $result -replace '深度传教士位肛交', '深插传教士位肛交'
    $result = $result -replace '臀部非常喜欢内射', '非常喜欢肛内射精'
    $result = $result -replace '２', '2'
    $result = $result -replace '３', '3'
    $result = $result -replace '４', '4'
    return $result
}

function Get-PositionText([string]$name) {
    if ($name -match '素股騎乗位') { return '接受方在上方跨坐，以大腿夹持男方摩擦，不进行插入。' }
    if ($name -match '素股後背位') { return '接受方背对主动方，从后方以大腿或臀沟夹持男方摩擦，不进行插入。' }
    if ($name -match '背面アナル駅弁|背面駅弁') { return '接受方背对主动方，由站立的主动方从身后抱起；名称含“アナル”时为肛交。' }
    if ($name -match '対面アナル駅弁|対面駅弁') { return '双方面对面，主动方站立抱起接受方；名称含“アナル”时为肛交。' }
    if ($name -match '駅弁') { return '主动方站立并抱起接受方进行，属于站立抱持姿势。' }
    if ($name -match '寄り添い側位') { return '双方侧卧并贴身进行，动作幅度较缓和。' }
    if ($name -match '台上側位|側位') { return '双方侧卧或横躺，从侧面进行；“台上”表示在台面上。' }
    if ($name -match '寝バック') { return '接受方俯卧，主动方从后方进入。' }
    if ($name -match '膝立ち.*後背位') { return '接受方跪姿背对主动方，由后方进入。' }
    if ($name -match '立ち後背位|背面立位|立位') { return '双方站立，接受方通常背向主动方，由后方进行。' }
    if ($name -match '後背位') { return '接受方背对或跪趴，主动方从后方进入。' }
    if ($name -match '背面.*騎乗位|背面騎乗位') { return '接受方在上方跨坐但背对主动方。' }
    if ($name -match '対面.*騎乗位|手繋ぎ.*騎乗位') { return '接受方在上方面对主动方跨坐，名称含“手繋ぎ”时双方牵手。' }
    if ($name -match '騎乗位') { return '接受方在上方跨坐并主导上下或前后动作。' }
    if ($name -match '正常位') { return '接受方仰卧，主动方在上，双方面对面。' }
    if ($name -match '対面.*座位') { return '双方面对面坐姿相拥进行。' }
    if ($name -match '背面座位') { return '接受方背对并坐在主动方腿上进行。' }
    if ($name -match '抱え込み.*座位') { return '接受方坐姿并收拢双腿，由主动方从后方或下方抱持。' }
    if ($name -match '松葉崩し') { return '接受方仰卧并抬起一腿，双方身体呈斜交的“松叶崩”姿势。' }
    if ($name -match 'まんぐり') { return '接受方仰卧，将双腿翻举向头侧，使臀部抬高。' }
    if ($name -match 'ブリッジ') { return '接受方以手脚支撑、躯干拱起成桥形。' }
    if ($name -match 'M字') { return '接受方屈膝并向两侧张开，双腿呈M字。' }
    if ($name -match '四つん這い') { return '接受方以双手与双膝支撑，呈跪趴姿势。' }
    if ($name -match 'テーブル') { return '在桌面或台面边缘进行。' }
    if ($name -match '椅子') { return '借助椅子，以坐姿或跨坐姿势进行。' }
    if ($name -match 'ベッド') { return '在床上进行。' }
    if ($name -match 'ソファー') { return '在沙发上进行。' }
    return $null
}

function Get-ActionTexts([string]$name) {
    $parts = [Collections.Generic.List[string]]::new()
    if ($name -match '2穴|２穴|両穴') {
        $parts.Add('同时针对阴道与肛门的双穴玩法')
    }
    elseif ($name -notmatch '素股' -and $name -match 'アナルセックス|アナル正常位|アナル後背位|アナル騎乗位|アナル立位|アナル座位|アナル駅弁|アナル側位|アナル寝バック') {
        $parts.Add('以肛门插入为主')
    }
    elseif ($name -notmatch '素股' -and $name -match 'セックス|正常位|後背位|騎乗位|寝バック|駅弁') {
        $parts.Add('以阴道插入为主')
    }

    if ($name -match '素股') { $parts.Add('以大腿夹住男方进行不插入的股间摩擦') }
    if ($name -match '愛撫') { $parts.Add('以抚摸、揉捏和敏感部位刺激为主') }
    if ($name -match 'オナニー') { $parts.Add('包含角色自慰') }
    if ($name -match 'ディルド') { $parts.Add('使用假阳具') }
    if ($name -match 'バイブ') { $parts.Add('使用震动棒刺激') }
    if ($name -match '電マ') { $parts.Add('使用电动按摩棒进行强烈刺激') }
    if ($name -match 'イラマ|ディープスロート') { $parts.Add('包含由主动方控制较强的深喉口交') }
    elseif ($name -match 'フェラ') { $parts.Add('包含口交') }
    if ($name -match '手コキ') { $parts.Add('用手刺激男方') }
    if ($name -match '足コキ') { $parts.Add('用脚刺激男方') }
    if ($name -match 'オナホコキ') { $parts.Add('以身体或手势模拟自慰器夹弄男方') }
    if ($name -match '逆アナル') { $parts.Add('由女方使用穿戴式或假阳具进入男方肛门，属于逆向肛交') }
    if ($name -match 'パイズリ') { $parts.Add('以胸部夹持摩擦男方') }
    if ($name -match 'シックスナイン') { $parts.Add('双方采用69式互相口交') }
    if ($name -match 'クンニ') { $parts.Add('包含为女性口交') }
    if ($name -match '貝合わせ') { $parts.Add('两名女性以外阴互相摩擦') }
    if ($name -match '玉舐め') { $parts.Add('包含舔舐睾丸') }
    if ($name -match '尻舐め|アナル舐め') { $parts.Add('包含舔舐臀部或肛周') }
    if ($name -match '全身舐め') { $parts.Add('包含全身舔舐') }
    if ($name -match '洗い|マットプレイ') { $parts.Add('采用泡泡浴式清洗、身体摩擦或垫上服务') }
    if ($name -match 'ポーズ') { $parts.Add('以摆姿势和身体展示为主') }
    if ($name -match '犬プレイ|わんちゃんプレイ') { $parts.Add('包含成人宠物犬角色扮演') }
    if ($name -match '拘束|吊るし|木馬|ギロチン|首絞め|鞭|ロウ|お仕置き|調教|被虐|羞恥責め|快楽責め') { $parts.Add('带有束缚、惩罚或SM演出') }
    if ($parts.Count -eq 0) { $parts.Add('按名称进行的情趣互动或姿势玩法') }
    return $parts
}

function Get-ContextTexts([string]$name) {
    $parts = [Collections.Generic.List[string]]::new()
    if ($name -match 'スワッピング') { $parts.Add('换伴情境') }
    if ($name -match '寝取らせ') { $parts.Add('由伴侣主动安排第三者参与的“寝取让渡”情境；“报告”版强调事后叙述') }
    if ($name -match '乱交|3P|３P|4P') { $parts.Add('多人参与') }
    if ($name -match 'ハーレム|ダブル') { $parts.Add('一男多女或双人协同') }
    if ($name -match '百合') { $parts.Add('女性同性互动') }
    if ($name -match '露出|公開|衆人環視') { $parts.Add('公开场所、露出或旁人观看情境') }
    if ($name -match 'ハメ撮り|AV撮影') { $parts.Add('带有拍摄或录像情境') }
    if ($name -match '酔い') { $parts.Add('醉酒状态变体') }
    if ($name -match '媚薬') { $parts.Add('媚药状态变体') }
    if ($name -match '目隠し') { $parts.Add('蒙眼情境') }
    if ($name -match '辱め|詰られ|説教|罵倒|言葉責め|反論封印') { $parts.Add('带有责骂、羞辱或言语挑逗演出') }
    if ($name -match '抵抗|押さえつけ') { $parts.Add('带有反抗或压制式剧情演出') }
    if ($name -match '結婚|らぶらぶ|イチャイチャ|激甘|母性|甘え|甘やかし') { $parts.Add('偏亲密、恋爱或宠溺氛围') }
    if ($name -match '種付け|孕ませ|中出し') { $parts.Add('受孕/内射主题') }
    return $parts
}

function Get-PlayType([string]$name) {
    $tags = [Collections.Generic.List[string]]::new()
    if ($name -match 'スワッピング|寝取らせ') { $tags.Add('换伴/NTR') }
    elseif ($name -match '乱交|3P|３P|4P|2穴|２穴') { $tags.Add('多人') }
    elseif ($name -match 'ハーレム|ダブル|百合') { $tags.Add('后宫/女性多人') }
    if ($name -match '拘束|吊るし|木馬|ギロチン|首絞め|鞭|ロウ|お仕置き|調教|被虐|羞恥責め|快楽責め') { $tags.Add('SM/拘束') }
    if ($name -match '露出|公開|衆人環視|ハメ撮り|AV撮影') { $tags.Add('公开/拍摄') }
    if ($name -match '逆アナル') { $tags.Add('逆向肛交') }
    elseif ($name -notmatch '素股' -and $name -match 'アナルセックス|アナル正常位|アナル後背位|アナル騎乗位|アナル立位|アナル座位|アナル駅弁|アナル側位|アナル寝バック') { $tags.Add('肛门性交') }
    elseif ($name -notmatch '素股' -and $name -match 'セックス|正常位|後背位|騎乗位|寝バック|駅弁') { $tags.Add('阴道性交') }
    if ($name -match '素股') { $tags.Add('股间摩擦') }
    if ($name -match 'フェラ|イラマ|クンニ|シックスナイン') { $tags.Add('口部服务') }
    if ($name -match '手コキ|足コキ|パイズリ|オナホコキ') { $tags.Add('手/足/胸部服务') }
    if ($name -match 'オナニー') { $tags.Add('自慰') }
    if ($name -match 'バイブ|ディルド|電マ') { $tags.Add('玩具刺激') }
    if ($name -match '愛撫|舐め|洗い|マットプレイ') { $tags.Add('爱抚/身体服务') }
    if ($name -match 'ポーズ|犬プレイ|わんちゃんプレイ') { $tags.Add('角色/姿势玩法') }
    if ($tags.Count -eq 0) { $tags.Add('情趣互动') }
    return ($tags | Select-Object -Unique) -join '｜'
}

function Get-Explanation([string]$name) {
    $sentences = [Collections.Generic.List[string]]::new()
    $actions = Get-ActionTexts $name
    if ($actions.Count -gt 0) { $sentences.Add((($actions | Select-Object -Unique) -join '；') + '。') }
    $position = Get-PositionText $name
    if ($position) { $sentences.Add($position) }
    $contexts = Get-ContextTexts $name
    if ($contexts.Count -gt 0) { $sentences.Add('情境要素：' + (($contexts | Select-Object -Unique) -join '、') + '。') }
    return $sentences -join ''
}

$raw = Import-Csv -LiteralPath $rawPath
$sources = if (Test-Path -LiteralPath $sourcePath) { Import-Csv -LiteralPath $sourcePath } else { @() }
$sourceById = @{}
foreach ($row in $sources) {
    if (-not $sourceById.ContainsKey($row.技能ID)) { $sourceById[$row.技能ID] = [Collections.Generic.List[string]]::new() }
    $sourceById[$row.技能ID].Add(($row.来源文件 -replace '^yotogi_skill_enabled_list_?', '' -replace '\.nei$', '' -replace '^$', 'base'))
}

$categoryOrder = @{'淫欲'=1;'奉仕'=2;'M性'=3;'詰られ'=4;'変態'=5;'交換'=6;'乱交'=7;'ハーレム'=8}
$organized = [Collections.Generic.List[object]]::new()
foreach ($group in ($raw | Group-Object 原分类,日文名)) {
    $first = $group.Group | Sort-Object {[int]$_.排序ID}, {[int]$_.技能ID} | Select-Object -First 1
    $ids = @($group.Group | ForEach-Object {[int]$_.技能ID} | Sort-Object)
    $src = foreach ($id in $ids) { if ($sourceById.ContainsKey([string]$id)) { $sourceById[[string]$id] } }
    $organized.Add([pscustomobject]@{
        分类顺序 = $categoryOrder[$first.原分类]
        类型 = $categoryMap[$first.原分类]
        原分类 = $first.原分类
        玩法类型 = Get-PlayType $first.日文名
        中文名称 = Convert-SkillName $first.日文名
        日文原名 = $first.日文名
        玩法与姿势说明 = Get-Explanation $first.日文名
        技能ID = $ids -join '、'
        同名ID数 = $ids.Count
        参与人数 = (@($group.Group | Select-Object -ExpandProperty 参与人数 -Unique | Sort-Object) -join '、')
        数据来源 = (@($src | Sort-Object -Unique) -join '、')
        排序ID = [int]$first.排序ID
        动作脚本 = (@($group.Group | Select-Object -ExpandProperty 动作脚本 -Unique | Where-Object {$_}) -join '、')
    })
}

$organized = @($organized | Sort-Object 分类顺序,排序ID,技能ID)
$organized | Select-Object 类型,玩法类型,中文名称,日文原名,玩法与姿势说明,技能ID,同名ID数,参与人数,数据来源,排序ID,动作脚本 |
    Export-Csv -NoTypeInformation -Encoding utf8BOM (Join-Path $here '陪夜技能_中文分类整理.csv')

$byId = foreach ($row in $raw) {
    $match = $organized | Where-Object { $_.原分类 -eq $row.原分类 -and $_.日文原名 -eq $row.日文名 } | Select-Object -First 1
    [pscustomobject]@{
        技能ID = [int]$row.技能ID
        类型 = $match.类型
        玩法类型 = $match.玩法类型
        中文名称 = $match.中文名称
        日文原名 = $row.日文名
        玩法与姿势说明 = $match.玩法与姿势说明
        排序ID = [int]$row.排序ID
        动作脚本 = $row.动作脚本
        参与人数 = $row.参与人数
        特殊状态 = $row.特殊状态
    }
}
$byId | Sort-Object 排序ID,技能ID | Export-Csv -NoTypeInformation -Encoding utf8BOM (Join-Path $here '陪夜技能_全830条ID明细.csv')

$summaryLines = [Collections.Generic.List[string]]::new()
$summaryLines.Add('# CUSTOM ORDER MAID 3D 2 陪夜技能中文分类整理')
$summaryLines.Add('')
$summaryLines.Add('- 数据来源：本机 `GameData/paths.dat` 所列并实际存在的 CSV 档案，以及其中的 `yotogi_skill_*.nei`。')
$summaryLines.Add(('- 游戏启用技能 ID：{0} 条；按“原分类 + 日文名称”去重后：{1} 项。' -f $raw.Count, $organized.Count))
$summaryLines.Add('- “玩法与姿势说明”依据游戏日文名称、分类、参与人数和动作关键词整理；原始数据本身没有独立的中文说明字段。')
$summaryLines.Add('')
$summaryLines.Add('## 分类统计')
$summaryLines.Add('')
$summaryLines.Add('| 类型 | 原分类 | ID数 | 去重玩法数 |')
$summaryLines.Add('|---|---:|---:|---:|')
foreach ($key in $categoryMap.Keys) {
    $idCount = @($raw | Where-Object 原分类 -eq $key).Count
    $uniqueCount = @($organized | Where-Object 原分类 -eq $key).Count
    $summaryLines.Add("| $($categoryMap[$key]) | $key | $idCount | $uniqueCount |")
}
$summaryLines.Add('')
$summaryLines.Add('## 字段说明')
$summaryLines.Add('')
$summaryLines.Add('- **类型**：将游戏内部八类日文分类翻译并改成更直观的中文。')
$summaryLines.Add('- **玩法类型**：依据名称识别性交部位、服务方式、多人/SM/公开等标签。')
$summaryLines.Add('- **中文名称**：保留情境修饰词与具体姿势的中文翻译。')
$summaryLines.Add('- **玩法与姿势说明**：解释主要动作、身体朝向、使用的道具以及多人情境。')
$summaryLines.Add('- **技能ID**：同名技能可能因性格或DLC存在多个ID，去重表中合并列出。')
$summaryLines.Add('')
$summaryLines.Add('## 结果文件')
$summaryLines.Add('')
$summaryLines.Add('- `陪夜技能_中文分类整理.csv`：推荐阅读，按玩法去重后的完整中文表。')
$summaryLines.Add('- `陪夜技能_全830条ID明细.csv`：逐技能ID明细，便于与游戏数据对应。')
$summaryLines.Add('- `陪夜技能_原始数据.csv`：直接从NEI提取的关键原始字段。')
$summaryLines.Add('- `启用技能ID来源.csv`：每个技能ID来自哪个启用列表。')
$summaryLines | Set-Content -Encoding utf8BOM (Join-Path $here 'README.md')

$catalogLines = [Collections.Generic.List[string]]::new()
$catalogLines.Add('# 陪夜技能中文目录（按玩法去重）')
$catalogLines.Add('')
$catalogLines.Add('> 共 541 项去重玩法；同名但属于不同性格或DLC的技能ID已合并。')
$catalogLines.Add('')
foreach ($key in $categoryMap.Keys) {
    $catalogLines.Add("## $($categoryMap[$key])（$key）")
    $catalogLines.Add('')
    $catalogLines.Add('| 玩法类型 | 中文名称 | 日文原名 | 玩法与姿势说明 | 技能ID |')
    $catalogLines.Add('|---|---|---|---|---|')
    foreach ($item in ($organized | Where-Object 原分类 -eq $key)) {
        $catalogLines.Add("| $($item.玩法类型) | $($item.中文名称) | $($item.日文原名) | $($item.玩法与姿势说明) | $($item.技能ID) |")
    }
    $catalogLines.Add('')
}
$catalogLines | Set-Content -Encoding utf8BOM (Join-Path $here '陪夜技能_中文分类整理.md')

$quality = [pscustomobject]@{
    原始启用ID数 = $raw.Count
    去重玩法数 = $organized.Count
    分类数 = @($organized | Select-Object -ExpandProperty 类型 -Unique).Count
    空中文名称 = @($organized | Where-Object { [string]::IsNullOrWhiteSpace($_.中文名称) }).Count
    空说明 = @($organized | Where-Object { [string]::IsNullOrWhiteSpace($_.玩法与姿势说明) }).Count
    未翻译假名名称 = @($organized | Where-Object { $_.中文名称 -match '[ぁ-ゖァ-ヺ]' }).Count
}
$quality | ConvertTo-Json | Set-Content -Encoding utf8BOM (Join-Path $here '翻译质量检查.json')
$quality | Format-List
