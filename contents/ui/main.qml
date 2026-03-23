import QtQuick
import QtQuick.Particles
import QtQuick3D
import QtQuick3D.Particles3D

import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper

    component SmoothAnimation: NumberAnimation {
        duration: 160
        easing.type: Easing.OutCubic
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0

        fillMode: wallpaper.configuration.FillMode
        source: wallpaper.configuration.Image

        readonly property int velocity: wallpaper.configuration.Velocity || 1000
        readonly property int numParticles: wallpaper.configuration.Particles
        readonly property int particleSize: wallpaper.configuration.Size || 200
        readonly property int particleLifeSpan: 1.5 * height / velocity
    }

    Item {
        id: overlayRoot
        anchors.fill: parent
        z: 2
        visible: wallpaper.configuration.OverlayImage !== ""

        QtObject {
            id: overlayEffect

            readonly property real maxTilt: 16
            readonly property real maxOffset: 14
            readonly property real sourceWidth: overlayImage.status === Image.Ready && overlayImage.sourceSize.width > 0 ? overlayImage.sourceSize.width : overlayRoot.width
            readonly property real sourceHeight: overlayImage.status === Image.Ready && overlayImage.sourceSize.height > 0 ? overlayImage.sourceSize.height : overlayRoot.height
            readonly property real sourceAspect: sourceHeight > 0 ? sourceWidth / sourceHeight : 1
            readonly property real targetAspect: overlayRoot.height > 0 ? overlayRoot.width / overlayRoot.height : 1
            readonly property bool preserveAspectFit: wallpaper.configuration.FillMode === Image.PreserveAspectFit || wallpaper.configuration.FillMode === Image.Pad
            readonly property real visualWidth: preserveAspectFit ? (sourceAspect > targetAspect ? overlayRoot.width : overlayRoot.height * sourceAspect) : overlayRoot.width
            readonly property real visualHeight: preserveAspectFit ? (sourceAspect > targetAspect ? overlayRoot.width / sourceAspect : overlayRoot.height) : overlayRoot.height
            readonly property real hoverWidth: overlayRoot.width
            readonly property real hoverHeight: overlayRoot.height
            property bool hovered: overlayMouseArea.containsMouse
            property real pointerX: hoverWidth / 2
            property real pointerY: hoverHeight / 2
            readonly property real normalizedX: normalize(pointerX, hoverWidth)
            readonly property real normalizedY: normalize(pointerY, hoverHeight)
            readonly property real targetTiltX: hovered ? -(normalizedY * maxTilt) : 0
            readonly property real targetTiltY: hovered ? normalizedX * maxTilt : 0
            readonly property real targetOffsetX: hovered ? normalizedX * maxOffset : 0
            readonly property real targetOffsetY: hovered ? normalizedY * maxOffset : 0
            readonly property real targetScale: hovered ? 1.02 : 1.0

            function clamp(value, minValue, maxValue) {
                return Math.max(minValue, Math.min(maxValue, value))
            }

            function normalize(value, size) {
                if (size <= 0) {
                    return 0
                }

                return clamp(((value / size) * 2) - 1, -1, 1)
            }

            function resetPointer() {
                pointerX = hoverWidth / 2
                pointerY = hoverHeight / 2
            }
        }

        Item {
            id: overlayVisual
            x: (overlayRoot.width - width) / 2
            y: (overlayRoot.height - height) / 2
            width: overlayEffect.visualWidth
            height: overlayEffect.visualHeight
            layer.enabled: overlayRoot.visible
            layer.smooth: true
            property real tiltX: overlayEffect.targetTiltX
            property real tiltY: overlayEffect.targetTiltY
            property real offsetX: overlayEffect.targetOffsetX
            property real offsetY: overlayEffect.targetOffsetY
            property real scaleFactor: overlayEffect.targetScale

            transform: [
                Translate {
                    x: overlayVisual.offsetX
                    y: overlayVisual.offsetY
                },
                Rotation {
                    origin.x: overlayVisual.width / 2
                    origin.y: overlayVisual.height / 2
                    axis.x: 1
                    axis.y: 0
                    axis.z: 0
                    angle: overlayVisual.tiltX
                },
                Rotation {
                    origin.x: overlayVisual.width / 2
                    origin.y: overlayVisual.height / 2
                    axis.x: 0
                    axis.y: 1
                    axis.z: 0
                    angle: overlayVisual.tiltY
                },
                Scale {
                    origin.x: overlayVisual.width / 2
                    origin.y: overlayVisual.height / 2
                    xScale: overlayVisual.scaleFactor
                    yScale: overlayVisual.scaleFactor
                }
            ]

            Behavior on tiltX {
                SmoothAnimation {}
            }

            Behavior on tiltY {
                SmoothAnimation {}
            }

            Behavior on offsetX {
                SmoothAnimation {}
            }

            Behavior on offsetY {
                SmoothAnimation {}
            }

            Behavior on scaleFactor {
                SmoothAnimation {}
            }

            Image {
                id: overlayImage
                anchors.fill: parent
                fillMode: wallpaper.configuration.FillMode
                source: wallpaper.configuration.OverlayImage
                visible: overlayRoot.visible
            }
        }

        Item {
            id: overlayHitArea
            x: 0
            y: 0
            width: overlayEffect.hoverWidth
            height: overlayEffect.hoverHeight
            visible: overlayRoot.visible

            MouseArea {
                id: overlayMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                onPositionChanged: {
                    overlayEffect.pointerX = mouseX
                    overlayEffect.pointerY = mouseY
                }

                onEntered: {
                    overlayEffect.pointerX = mouseX
                    overlayEffect.pointerY = mouseY
                }

                onExited: {
                    overlayEffect.resetPointer()
                }
            }
        }
    }

    View3D {
        anchors.fill: parent
        z: 1

        environment: SceneEnvironment {
            clearColor: "#202020"
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 600)
            clipFar: 20007
        }

        PointLight {
            position: Qt.vector3d(200, 600, 400)
            brightness: 40
            ambientColor: Qt.rgba(0.2, 0.2, 0.2, 1.0)
        }

        ParticleSystem3D {
            id: lightRain
            y: 2000

            ParticleEmitter3D {
                id: lightRainEmitter
                emitRate: backgroundImage.numParticles
                lifeSpan: 500
                particle: lightRainParticle
                particleScale: 0.75
                particleScaleVariation: 0.25
                velocity: lightRainDirection
                shape: lightRainShape
                depthBias: -200

                VectorDirection3D {
                    id: lightRainDirection
                    direction.y: -(lightRain.y * 2)
                }

                SpriteParticle3D {
                    id: lightRainParticle
                    color: "#90e6f4ff"
                    maxAmount: 300
                    particleScale: 200
                    fadeInDuration: 0
                    fadeOutDuration: 20
                    fadeOutEffect: Particle3D.FadeOpacity
                    sortMode: Particle3D.SortDistance
                    sprite: lightRainTexture
                    offsetY: 1
                    billboard: true

                    Texture {
                        id: lightRainTexture
                        source: wallpaper.configuration.Rainflake
                    }

                    SpriteSequence3D {
                        id: lightRainSequence
                        duration: 15
                        randomStart: true
                        animationDirection: SpriteSequence3D.Normal
                        frameCount: 3
                        interpolate: true
                    }
                }
            }

            ParticleShape3D {
                id: lightRainShape
                extents.x: 500
                extents.y: 0.5
                extents.z: 500
                type: ParticleShape3D.Cube
                fill: true
            }

            TrailEmitter3D {
                id: lightRainSplashEmitter
                emitRate: 0
                lifeSpan: 800
                particle: lightRainSplashParticle
                particleScale: 15
                particleScaleVariation: 15
                follow: lightRainParticle
                emitBursts: lightRainSplashBurst
                depthBias: -10

                SpriteParticle3D {
                    id: lightRainSplashParticle
                    color: "#8bc0e7fb"
                    maxAmount: 250
                    sprite: lightRainSplashTexture
                    spriteSequence: lightRainSplashSequence
                    fadeInDuration: 450
                    fadeOutDuration: 800
                    fadeInEffect: Particle3D.FadeScale
                    fadeOutEffect: Particle3D.FadeOpacity
                    sortMode: Particle3D.SortDistance
                    billboard: true
                    offsetY: 1

                    Texture {
                        id: lightRainSplashTexture
                        source: "data/splash7.png"
                    }

                    SpriteSequence3D {
                        id: lightRainSplashSequence
                        duration: 800
                        frameCount: 6
                    }
                }

                DynamicBurst3D {
                    id: lightRainSplashBurst
                    amount: 1
                    triggerMode: DynamicBurst3D.TriggerEnd
                }
            }
        }
    }
}
