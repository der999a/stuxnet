# Stuxnet: карта портирования и сборки

Stuxnet основан на официальном `TelegramMessenger/Telegram-iOS`. AyuGram и Swiftgram используются как референсы поведения и интерфейса, но код переносится в архитектуру Telegram-iOS: `TelegramCore`, `Postbox`, `TelegramUI` и `SettingsUI`.

## Текущий статус

| Область | Статус | Реализация |
| --- | --- | --- |
| Брендинг | Реализовано | Видимое имя Stuxnet, bundle display names, Watch App и полный набор app icons. |
| Настройки Stuxnet | Реализовано | Отдельный modification center с Ghost Mode, историей сообщений, подтверждениями отправки, визуальной лабораторией и редактором профильных подарков. |
| Ghost Mode | Реализовано, требуется device test | Подавление read receipts, story views, online presence и upload activities в центральных TelegramCore-хуках. |
| Delayed ghost sending | Реализовано, требуется CI/device test | Обычная отправка преобразуется в Telegram scheduled message на 10–60 секунд вперёд. По умолчанию 12 секунд, как безопасный аналог AyuGram. |
| Anti-recall | Реализовано, требуется длительный тест | Входящее сообщение, уже находящееся в локальном Postbox, сохраняется при серверном удалении и помечается локальным атрибутом. |
| История редактирования | Реализовано | До 100 локальных текстовых ревизий, действие `Edit history` в context menu. |
| Детали сообщения | Реализовано | Peer/message IDs, namespaces, author/thread IDs, timestamp, направление, deletion state и число ревизий. |
| Визуал удалённых сообщений | Реализовано | Настраиваемая подпись в timestamp/status и опциональное нативное приглушение bubble/sticker/instant-video content. |
| Компактный список чатов | Реализовано | Уменьшенные вертикальные размеры элементов списка. |
| Chats & Appearance | Реализовано, требуется CI/device test | Нативный Telegram message preview, интерактивный радиус bubble, отключение tails/share, прозрачность удалённых сообщений и сгруппированные настройки списка/времени/activity. |
| Скрытие аватаров списка | Реализовано, требуется device test | Для обычных chat rows убирается avatar и возвращается место тексту; forum/community/inline structural icons сохраняются. |
| Скрытие typing activity | Реализовано, требуется network test | Подавляются typing, recording, sticker-selection и emoji-interaction actions; uploads и group-call speaking контролируются отдельно. |
| Точные timestamps | Реализовано | Независимые секунды/дата для сообщений и списка чатов; локальные или английские короткие месяцы. |
| Локальное скрытие телефона | Реализовано | Номер скрывается в профилях и Settings, не изменяя Telegram privacy или контактную базу. |
| Число аккаунтов | Реализовано | Практический лимит клиента увеличен до 100 аккаунтов. Серверные ограничения Telegram не изменяются. |
| Профильные gifts | Реализовано как decoration, требуется CI/device test | Импорт из кэшированного Telegram catalog по ID или collectible slug, нативная анимация и карточки, show/hide, pin, wear, model/pattern/backdrop и локальная история перемещений. |
| Voice Lab | Реализовано, требуется CI/device/audio test | Общий stateful DSP подключён к voice messages, story voice replies, round videos, private calls и group calls; области применения включаются отдельно. |
| Rear-camera round videos | Реализовано, требуется device test | Отдельная настройка выбирает заднюю камеру при первом открытии записи кружка. |
| Подтверждения действий | Реализовано частично, требуется UI test | Текст, media/files/stickers через основной send path, звонки, подписка на broadcast channel, story replies и story reactions/likes. Подтверждение самого открытия истории пока не проведено через все entry points. |
| Face ID / Touch ID chat lock | Реализовано, требуется device/background test | Контент чата закрывается overlay до биометрии, список и уведомления скрывают preview, при уходе приложения чат блокируется повторно. |
| Chat export JSON/HTML | Не реализовано | Полный экспорт требует отдельного обхода всей истории и media с корректной обработкой holes, topics, secret chats и ограничений доступа; частичный экспорт кэша не выдаётся за полный. |
| Локальные Stars/TON | Реализовано как decoration | Настраиваемые значения отображаются в собственном профиле и не меняют Telegram/TON balances. |
| Настоящие Stars/TON/gift purchases | Намеренно не реализуется | Клиент не подделывает Telegram payments, ownership, blockchain state или серверные транзакции. |
| Альтернативный MTProto server | Отдельный продуктовый режим | MyTelegram/OwpenGram требуют собственных DC/RSA/server endpoints и несовместимы с прозрачным добавлением возможностей в обычный Telegram account. |
| TDLib | Только референс | Telegram-iOS уже имеет собственные MTProto/Postbox/engine слои; второй networking stack не добавляется. |

## Ghost scheduled sending

Настройки:

- `Delayed sending in Ghost Mode` включает преобразование обычной отправки;
- `Send delay` принимает значение от 10 до 60 секунд;
- преобразование работает только при полном состоянии `Ghost Mode`;
- уже запланированные сообщения не изменяются.

Для стабильности преобразование пропускается для:

- secret chats и Saved Messages;
- bot dialogs;
- channels с активной slow mode configuration;
- story replies и service actions;
- inline-bot, quick-reply, paid Stars и suggested-post sends;
- forwards на первом этапе портирования.

Telegram сам хранит и доставляет scheduled message. На протяжении короткой задержки сообщение может отображаться в scheduled/local pending state — это ожидаемое поведение протокола, а не полностью локальный таймер.

Основной хук: `submodules/TelegramCore/Sources/PendingMessages/EnqueueMessage.swift`.

## Anti-recall и edit history

Локальные атрибуты:

- `StuxnetDeletedMessageAttribute` фиксирует серверное удаление;
- `StuxnetMessageHistoryAttribute` хранит предыдущие версии текста;
- оба типа регистрируются в Postbox encoder, поэтому переживают перезапуск приложения.

Ограничения anti-recall:

- можно сохранить только то, что уже было загружено в локальный Postbox;
- удалённые до первой синхронизации сообщения восстановить невозможно;
- Telegram может отозвать недоступное/expired media с CDN, даже если локальная запись сообщения сохранена;
- bot chats по умолчанию исключены и включаются отдельной настройкой;
- после изменения схемы необходимы тесты обновления существующей базы и cold restart.

Основные хуки:

- `submodules/TelegramCore/Sources/State/AccountStateManagementUtils.swift`;
- `submodules/TelegramCore/Sources/SyncCore/StuxnetMessageAttributes.swift`;
- `submodules/TelegramUI/Sources/ChatInterfaceStateContextMenus.swift`;
- `submodules/TelegramUI/Components/Chat/ChatMessageDateAndStatusNode/Sources/StringForMessageTimestampStatus.swift`.

## Локальные профильные decoration

Stuxnet local Stars, TON и gifts предназначены для тем, макетов, демонстрации и персонального оформления. Они:

- видны только в этом клиенте и на этом устройстве;
- не отправляются в Telegram API;
- не доказывают владение подарком, username, anonymous number, Premium или криптоактивом;
- не должны визуально выдаваться за подтверждённую серверную покупку.

Если понадобится поддержка реальных активов, она должна читать только подтверждённые Telegram API/TON данные и использовать официальный flow авторизации/оплаты.

### Подарки в профиле

Экран `Stuxnet → Gifts` использует настоящий кэш каталога Telegram и позволяет:

- обновить каталог и добавить обычный подарок по его numeric ID;
- получить collectible по полному `t.me/nft/...` link или slug;
- открыть штатный animated `GiftViewScreen` preview;
- включить или скрыть подарок в собственном профиле;
- закрепить один featured gift и отдельно выбрать один worn gift;
- получить доступные с сервера model, pattern и backdrop variants, выбирать их в отдельных списках и задавать отображаемый номер;
- вернуть исходное оформление;
- изменить локальное имя владельца и сохранить историю локальных перемещений.

В профиле такие элементы объединяются с реальным `ProfileGiftsContext` только на UI-уровне. Сетка строится штатным `GiftItemComponent`, pinned/worn collectibles участвуют в штатной декорации profile cover, а открытие локального preview имеет только кнопку `Done` и не вызывает Telegram wear/transfer/payment methods. Серверные gifts, references, покупки, ownership и blockchain state не изменяются.

Основные файлы:

- `submodules/TelegramCore/Sources/Settings/StuxnetSettings.swift`;
- `submodules/SettingsUI/Sources/Stuxnet/StuxnetLocalGiftsController.swift`;
- `submodules/TelegramUI/Components/PeerInfo/PeerInfoVisualMediaPaneNode/Sources/GiftsListView.swift`;
- `submodules/TelegramUI/Components/PeerInfo/PeerInfoCoverComponent/Sources/PeerInfoGiftsCoverComponent.swift`.

## Подтверждение отправки

В `Stuxnet → Message History` есть независимые переключатели подтверждения текста и media/files. Перед фактическим enqueue показывается штатный alert; повторный вызов после нажатия `Send` помечается как подтверждённый, поэтому рекурсивного alert нет. Тип media определяется не только вызывающим flow, но и наличием `mediaReference` в `EnqueueMessage`.

Основной хук: `submodules/TelegramUI/Sources/ChatController.swift`.

Подтверждения story replies и reactions/likes находятся в `StoryContainerScreen`. Открытие самой истории остаётся отдельной задачей: простой alert после показа экрана недостаточен, потому что view receipt может быть поставлен в очередь раньше. Для корректной реализации нужен единый gate до создания story session и до `markStoryAsSeen` для всех entry points.

## Voice Lab

Voice Lab использует один DSP из `submodules/AccountContext/Sources/VoiceLabProcessor.swift`. Настройки независимо выбирают применение к:

- voice messages и голосовым ответам на истории;
- аудиодорожке записываемых round videos;
- private calls, group calls и voice chats, использующим общий WebRTC audio device.

Обработка выполняется до Telegram encoding/network transport. Коэффициенты фильтров вычисляются при создании процессора, state и PCM-буферы переиспользуются, тригонометрия генераторов заменена заранее прогретой общей lookup-таблицей, а нейтральный pitch не создаёт большую delay line. В PCM sample loop нет выделений памяти. Call bridge принимает только штатный WebRTC Int16 PCM; неизвестные форматы пропускаются без изменения.

Пресеты `Anonymous Deep` и `Anonymous Flux` усиливают изменение тембра time-varying delay, nonlinear shaping и небольшим шумом со случайным seed для каждой сессии обработки. Это privacy-hardening, а не доказанная необратимость: нельзя обещать, что обработанный голос невозможно сопоставить или восстановить любым методом.

Основные точки интеграции:

- `submodules/TelegramUI/Sources/ManagedAudioRecorder.swift`;
- `submodules/TelegramUI/Components/VideoMessageCameraScreen/Sources/VideoMessageCameraScreen.swift`;
- `submodules/TgVoipWebrtc/Sources/OngoingCallThreadLocalContext.mm`;
- `submodules/TelegramCallsUI/Sources/SharedCallAudioContext.swift`.

## Chats & Appearance

Экран `Stuxnet → Chats & Appearance` построен на штатных компонентах Telegram-iOS:

- `ThemeSettingsChatPreviewItem` рендерит настоящее сообщение на текущих theme/wallpaper;
- preview показывает reply `gamesense when?` и текст `ask latviankult`;
- `BubbleSettingsRadiusItem` меняет радиус от 8 до 16 с обновлением preview;
- `PresentationChatBubbleCorners.hasTails` управляет хвостами bubble;
- side Share скрывается в обычных сообщениях, но обязательное действие рекламы сохраняется;
- hidden chat-list avatars меняют layout inset, а не только делают картинку прозрачной;
- typing/recording privacy применяется перед `messages.setTyping`, поэтому действие не уходит в MTProto.

Основные файлы:

- `submodules/SettingsUI/Sources/Stuxnet/StuxnetChatsController.swift`;
- `submodules/TelegramUI/Sources/ChatController.swift`;
- `submodules/TelegramUI/Components/Chat/ChatMessageBubbleItemNode/Sources/ChatMessageBubbleItemNode.swift`;
- `submodules/ChatListUI/Sources/Node/ChatListItem.swift`;
- `submodules/TelegramCore/Sources/State/ManagedLocalInputActivities.swift`.

## GitHub Actions

Workflow: `.github/workflows/build.yml`.

Он запускается:

- на push в `main` или `master`;
- на pull request в `main` или `master`;
- вручную через `workflow_dispatch`;
- для тега `stuxnet-v*`, после успешной сборки также создаёт GitHub Release.

Сборка использует:

- runner `macos-26`;
- Xcode из `versions.json` (`26.2`);
- Telegram `Make.py` и Bazel configuration `release_arm64`;
- fake code signing из официального build system.

Артефакты:

- `Stuxnet.ipa`;
- `Stuxnet.DSYMs.zip`;
- retention обычного artifact — 14 дней;
- tagged release хранит приложенные файлы по правилам GitHub Releases.

Fake-signed/unsigned IPA подтверждает компиляцию и упаковку, но не устанавливается на обычное физическое устройство без повторной подписи. Для TestFlight/App Store или прямой установки нужны Apple Developer Team, certificates, provisioning profile, entitlements и уникальные bundle identifiers.

GitHub Actions для public repositories обычно не списывает стандартные hosted-runner minutes, но macOS/private-repository billing и лимиты зависят от текущего GitHub plan. Перед частыми сборками нужно проверить `Settings → Billing and licensing → Actions` в репозитории/организации.

## Подключение репозитория Stuxnet

Текущий `origin` оставлен на официальном Telegram-iOS намеренно. Безопаснее добавить отдельный remote, чтобы сохранить возможность сравнения с upstream:

```bash
git config user.name "YOUR_GITHUB_NAME"
git config user.email "YOUR_GITHUB_EMAIL"
git remote add stuxnet https://github.com/der999a/stuxnet.git
git add -A
git commit -m "Build Stuxnet iOS client"
git push -u stuxnet master:main
```

Перед первым push необходимо явно проверить `git status --short` и решить, какие untracked файлы входят в репозиторий. `.vs/` и полная копия `ayugram/` уже исключены корневым `.gitignore`. `stuxnet.png` и `StuxnetAppIconMaster.png` можно хранить как branding sources. Первый push существующей истории Telegram-iOS большой (локальный pack около 865 MiB), поэтому загрузка может занять заметное время.

После push открыть `Actions → Stuxnet iOS CI → Run workflow` либо дождаться автоматического запуска на `main`. Первый зелёный workflow является обязательным compiler gate; при ошибке нужно исправлять конкретную диагностику Swift/Objective-C++/Bazel и перезапускать job.

## Проверка перед публикацией

Минимальный gate:

1. `git diff --check` без ошибок whitespace.
2. `actionlint .github/workflows/build.yml`.
3. Успешный GitHub Actions build на чистом checkout с recursive submodules. Workflow также проверяет plist, обязательные Stuxnet sources, наличие app-icon файлов и отдельно компилирует/запускает быстрый Int16/Float32 Voice Lab smoke-test до полной Bazel-сборки.
4. Cold launch и миграция существующего Postbox.
5. Отправка текста, фото, видео, album, reply и scheduled message с Ghost Mode включённым/выключенным.
6. Проверка исключений: bot, secret chat, slow mode, inline bot, Stars-paid message, suggested post.
7. Удаление и редактирование сообщений в private chat, group, channel comments и forum topic.
8. Перезапуск приложения после сохранения deleted/edit-history attributes.
9. VoiceOver и context-menu проверка на коротком и очень длинном тексте.
10. Реальное устройство минимум на двух поддерживаемых версиях iOS.

До прохождения CI и device matrix проект нельзя честно называть полностью проверенным или bug-free.
