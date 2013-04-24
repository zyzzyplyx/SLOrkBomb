using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace Tablet_Control
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        /// <summary>
        /// Object to output data to OSC
        /// </summary>
        //private UdpWriter udpwriter;

        public MainPage()
        {
            this.InitializeComponent();
        }

        private TranslateTransform dragTranslation;
        void Drag_ManipulationDelta(object sender,
                                    ManipulationDeltaRoutedEventArgs e)
        {
            // Move the rectangle.
            dragTranslation.X += e.Delta.Translation.X;
            dragTranslation.Y += e.Delta.Translation.Y;
        }

        /// <summary>
        /// Invoked when this page is about to be displayed in a Frame.
        /// </summary>
        /// <param name="e">Event data that describes how this page was reached.  The Parameter
        /// property is typically used to configure the page.</param>
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            //this.udpwriter = new UdpWriter("192.168.187.54", 12345);

            TestRectangle.ManipulationDelta += Drag_ManipulationDelta;
            dragTranslation = new TranslateTransform();
            TestRectangle.RenderTransform = this.dragTranslation;
        }
    }
}
