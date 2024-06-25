const hyprland = await Service.import("hyprland")

const dispatch = (workspace) => hyprland.messageAsync(`dispatch workspace ${workspace}`)

const Workspaces = (monitor) => Widget.Box({
    children: Array.from({ length: 10 }, (_, index) => index + 1).map((number) => Widget.Button({
        attribute: number,
        label: `${number}`,
        onClicked: () => dispatch(number),
    })),
    setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
        btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute && ws.monitorId === monitor)
    })),
})

const date = Variable("", {
    poll: [1000, 'date "+%Y-%m-%d %H:%M:%S (%A|%B)"']
})

const Clock = () => Widget.Label({
    label: date.bind(),
}) 

const Bar = (monitor) => {
    return Widget.Window({
        name: `bar-${monitor}`,
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.Box({
            spacing: 8,
            children: [
                Workspaces(monitor),
                Clock(),
            ]
        }),

    })
}

App.config({
    windows: [
        Bar(0),
        Bar(1),
    ],
})